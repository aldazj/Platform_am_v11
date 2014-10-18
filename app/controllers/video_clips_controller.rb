#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class VideoClipsController < ApplicationController
  #Filtres
  before_action :set_video_clip, only: [:show, :edit, :update, :destroy]
  before_filter :signed_in_person

  #Libraries ruby utilisées
  require 'json'
  require 'open-uri'
  #require 'aws/s3' si on veut utiliser directement l'API amazon

  #Buffer qui est utilisé lors d'un téléchargement de vidéo
  #La majeur partie des systèmes d'exploitation sont
  #configurés pour utiliser bloques de taille 4096 ou 8192
  BUFFER_SIZE = 8*1_024

  #Le parametre q (moyen de faire récupère ce qu'un utilisateur entre) est definit dans la librarie tokeninput
  #Lire cette documentation pour comprendre http://loopj.com/jquery-tokeninput/
  # GET /video_clips
  # GET /video_clips.json
  def index
    #@video_clips = VideoClip.all
    @video_clips  = VideoClip.search_video(params[:q], current_person).paginate(:per_page => 3, :page => params[:page])
  end

  #On récupère les videos qui ne sont pas disponibles
  def indexUnavailable
    @video_clips_unavailable = VideoClip.search_video_unavailable(params[:q], current_person).paginate(:per_page => 2, :page => params[:page])
  end

  #On affiche une video. Pour cela on vérifie si on a accès à son contenu.
  #On incrémente la valeur vues
  #On recupère toutes les informations de la vidéo. (Commentaires, propriétaire...)
  # GET /video_clips/1
  # GET /video_clips/1.json
  def show
    verify_access_video(@video_clip, 'show')
    @video_clip.increment!(:views)
    @video_clip = VideoClip.find_by_token(params[:id])
    #@video_clip_comments = @video_clip.comments.order("id DESC").paginate(:per_page => 3, :page => params[:page])
    @owner = Person.find_by_id(@video_clip.person_id)
    @new_comment = @video_clip.comments.build

    #On récupère le bon URL de la vidéo.
    #(La vidéo peut être stockée en Amazon S3 ou dans un autre serveur)
    if @video_clip.videoclip_from_url.empty?
      @file_video = @video_clip.videoitemclip.url
    else
      @file_video = @video_clip.videoclip_from_url
    end

    #On récupère la vignette qui a été sélectionnée pour
    #représenter la vidéo
    @thumb_main = nil
    @video_clip.thumbnails.each do |thumbnail|
      if thumbnail.main_thumbnail == true
        @thumb_main = thumbnail
        break
      end
    end

    #On enregistre l'activité
    @video_clip.create_activity :show, owner: current_person

  end

  #Lorsqu'on veut créer une vidéo on donne la possibilité
  #de rajouter des vignettes supplémentaires
  # GET /video_clips/new
  def new
    verify_access_video(@video_clip, 'new')
    @video_clip = VideoClip.new
    @video_clip.thumbnails.build
  end

  #Lorsqu'on veut éditer une vidéo on donne la possibilité
  #de rajouter une vignette, et de voir les commentaires
  #associés à cette vidéo
  # GET /video_clips/1/edit
  def edit
    verify_access_video(@video_clip, 'edit')
    @video_clip.thumbnails.build
    @video_clips_comments = @video_clip.comments
  end

  #Quand on charge une vidéo dans la plateforme:
  # POST /video_clips
  # POST /video_clips.json
  def create
    #On crée une instance de la vidéo à enregistrer
    @video_clip = VideoClip.new(video_clip_params)

    #On vérifie les groupes selectionnés qui peuvent voir la vidéo
    groups_video_clip_selection(params[:video_clip][:group_ids])

    #On crée une liste qui stockera les vignettes générées
    thumbnails = Array.new
    #Le nombre de vue est mis à zero
    @video_clip.views = 0
    #On met la personne qui a ajouté la vidéo
    @video_clip.person_id = current_person.id

    respond_to do |format|
      #On stocke la vidéo
      if @video_clip.save

        #Une fois que la video est enregistrée et que ce n'est pas une vidéo distante. Alors
        #On analyse la video avec la libraire FFMPEG
        if (@video_clip.videoclip_from_url.empty?)
          #Nous créons un dossier où seront stockés les vignettes, les conversions d'une vidéo
          filename = @video_clip.videoitemclip_file_name.split('.')[0..-1][0].to_s
          path_local_dir = @video_clip.videoitemclip.path.to_s
          url_file_s3 = @video_clip.videoitemclip.url
          createDirectory(path_local_dir)

          #Nous obtenons le temps total en seconde d'une vidéo
          time_video_mp4_sec = get_time_videomp4_in_sec(url_file_s3, "Duration").gsub(/\n$/,'').to_i
          #A partir du temps total, on fait un simple calcul pour trouver
          # le temps nécessaire pour générer une vignette tout les 20% d'une vidéo
          shift_time = ((time_video_mp4_sec*20).to_f/100)
          step = 1
          time_tmp = 0

          #Tant qu'on n'est pas à la fin du fichier,
          # tout les 20% on crér une vignette.
          while time_tmp < time_video_mp4_sec
            thumbnail = generate_thumbnail_from_video(filename, path_local_dir, time_tmp, step, url_file_s3)
            thumbnails << thumbnail
            time_tmp += shift_time
            step += 1
          end

          #Une fois que les vignettes ont été crées, elles sont
          # stockées sur AmazonS3 grâce à Paperclip
          storeThumbnailsOnAmazonS3(thumbnails)

        end

        #On fait appel à notre module wicked! Où l'utilisateur pourra voir les
        #vignettes générées, effacer des vignettes si elle sont moches, ajouter
        #de vignettes supplémetaires , et selectionner la vignette qui représentera
        #la vidéo
        format.html{ redirect_to video_clip_steps_path(:video_clip_id => @video_clip.id) }
        format.json { render action: 'show', status: :created, location: @video_clip }
      else
        format.html { render action: 'new' }
        format.json { render json: @video_clip.errors, status: :unprocessable_entity }
      end

    end
  end

  #On met à jour le contenu d'une vidéo
  # PATCH/PUT /video_clips/1
  # PATCH/PUT /video_clips/1.json
  def update
    #On se rassure qu'une seule vignette soit séléctionnée
    select_thumbnail = 0
    @video_clip.thumbnails.each do |thumbnail|
      if thumbnail.id == params[:main_thumbnail].to_i
        thumbnail.main_thumbnail = true
        select_thumbnail += 1
      else
        thumbnail.main_thumbnail = false
      end
    end

    #On vérifie les groupes selectionnés qui peuvent voir la vidéo
    groups_video_clip_selection(params[:video_clip][:group_ids])

    respond_to do |format|
      #On met à jour notre video
      if @video_clip.update(video_clip_params) && select_thumbnail == 1
        #On enregiste l'activité
        @video_clip.create_activity :update, owner: current_person
        format.html { redirect_to @video_clip, notice: 'Video clip was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @video_clip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /video_clips/1
  # DELETE /video_clips/1.json
  def destroy
    verify_access_video(@video_clip, 'delete')
    @video_clip.destroy
    respond_to do |format|
      format.html { redirect_to video_clips_url }
      format.json { head :no_content }
    end
  end

  #Function qui se charge du téléchargement
  def download
    video_clip = VideoClip.find_by_token(params[:id])
    file_name = nil
    out_file = nil

    #On crée le dossier où sont mis toutes les vidéos téléchargées de AmazonS3
    #ou d'un autre seveur.
    dir = File.join( Rails.root, 'public' , 'system', 'downloads')
    FileUtils.mkdir_p(dir) unless File.directory?(dir)

    #On récupère correctement l'information de la vidéo (nom, path...)
    if video_clip.videoclip_from_url.empty?
      video_clip_url = video_clip.videoitemclip.url
      file_name = video_clip.videoitemclip_file_name
      file_path_local = File.join(dir, "#{file_name}")
    else
      video_clip_url = video_clip.videoclip_from_url
      file_name = File.basename(URI.parse(video_clip_url).path)
      file_path_local = File.join(dir, "#{video_clip_url.split(/\//).last}")
    end

    #On crée un fichier où on va copier le contenu téléchargé
    out_file = File.new(file_path_local, 'wb')

    #On écrit le contenu du fichier sur celui qu'on vient de créer.
    open(video_clip_url, "r",
         :content_length_proc => lambda {|content_length| puts "Content length: #{content_length} bytes" },
         :progress_proc => lambda { |size| printf("Read %010d bytes\r", size.to_i) }) do |input|
      open(out_file, "wb") do |output|
        while (buffer = input.read(BUFFER_SIZE))
          output.write(buffer)
        end
      end
    end

    #On envoie le fichier au browser.
    send_file( out_file.path,
              :filename      =>  file_name,
              :x_sendfile    => true)

    #On enregistre l'activité
    video_clip.create_activity :download, owner: current_person
  end

  #On vérifie si la personne est connectée
  def signed_in_person
    redirect_to signin_path, notice: 'Please sign in.' unless signed_in?
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_video_clip
    @video_clip = VideoClip.find_by_token(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def video_clip_params
    params.require(:video_clip).permit(:title, :description, :is_available, :date, :views, :videoitemclip, :delete_at, :videoclip_from_url,
                                       thumbnails_attributes: [:id, :image, :_destroy, :main_thumbnail],
                                       formatvideos_attributes: [:id, :format, :_destroy],
                                       comments_attributes: [:id, :message, :is_available, :date, :url_for, :_destroy])
  end


  #On vérifie les groupes selectionnés qui peuvent voir la vidéo
  def groups_video_clip_selection(video_clip_groups_param)
    # On vérifie qu'un video clip n'est visible par aucun groupe
    @video_clip.groups.clear if !@video_clip.groups.empty?
    video_clip_groups_param ||= []

    #On attribue à une personne différents groupes choisis un utilisateur
    video_clip_groups_param.each do |group|
      if !(group.blank?)
        @video_clip.add_group(Group.find_by_id(group))
      end
    end
  end

######################################################
#  Pour les commandes FFMPEF lire la documentation
#
######################################################

  #Convertit une video mp4 en flv
  def convert_video_to_flv(filename, path, content, url)
    logger.debug "Convert the video ( #{filename} ) path ( #{path}) from content type of #{content} to flv"
    File.new(File.join(Rails.root, 'public' , 'system', File.dirname(path), "#{filename}.flv"), File::CREAT | File::TRUNC| File::RDWR, 0644)
    videoflv = File.join(Rails.root, 'public' , 'system', File.dirname(path), "#{filename}.flv")
    system("ffmpeg -i #{url} -r 25 -ar 44100 -vcodec flv -ab 32 -y -f flv -s 320x240 #{videoflv}")
    return videoflv
  end

  #Convertit une video mp4 en H264
  def convert_video_to_H264(filename, path, content, url)
    logger.debug "Convert the video ( #{filename} ) path ( #{path}) from content type of #{content} to H264"
    File.new(File.join(Rails.root, 'public' , 'system', File.dirname(path), "#{filename}.h264"), File::CREAT | File::TRUNC| File::RDWR, 0644)
    videoh264 = File.join(Rails.root, 'public' , 'system', File.dirname(path), "#{filename}.h264")
    system("ffmpeg -i #{url} -an -vcodec libx264 -crf 23 #{videoh264} -y")
    return videoh264
  end

  #Convertit une video mp4 en avi
  def convert_video_to_AVI(filename, path, content, url)
    logger.debug "Convert the video ( #{filename} ) path ( #{path}) from content type of #{content} to H264"
    File.new(File.join(Rails.root, 'public' , 'system', File.dirname(path), "#{filename}.avi"), File::CREAT | File::TRUNC| File::RDWR, 0644)
    videoavi = File.join(Rails.root, 'public' , 'system', File.dirname(path), "#{filename}.avi")
    system("ffmpeg -i #{url} -acodec copy -vcodec copy #{videoavi} -y")
    return videoavi
  end

  #On crée un dossier
  def createDirectory(path)
    dir = File.dirname(File.join( Rails.root, 'public' , 'system', path))
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
  end

  #Commande qui répurère le temps en secondes d'une vidéo
  def get_time_videomp4_in_sec(video_flv, duration)
    return `ffmpeg -i #{video_flv} 2>&1 | grep #{duration}| cut -d ' ' -f 4 | sed s/,// | sed 's@\\..*@@g' | awk '{ split($1, A, ":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }'`
  end


  #On génère des vignettes à partir d'une vidéo
  def generate_thumbnail_from_video(filename, path_local_dir, time, step, url_file_s3)
    logger.debug "Trying to generate screenshots from #{url_file_s3}"
    asset = File.join(Rails.root, 'public' , 'system', File.dirname(path_local_dir), "#{filename}_#{step}.jpg")
    File.new(asset, File::CREAT | File::TRUNC| File::RDWR, 0644)
    system("ffmpeg -ss #{time} -i #{url_file_s3} -s 320x240 -vframes 1 -f image2 -an #{asset} -y")
    return asset
  end

  #On envoie la video convertie sur Amazon S3
  def storeFormatOnAmazonS3(videomp4, videoconverted, format)
    Formatvideo.create({
                           :video_clip_id => videomp4.id,
                           :format =>  File.open(videoconverted),
                           :type => format
                       })
  end

  #On envoie chaque vignette générée sur Amazon S3
  def storeThumbnailsOnAmazonS3(thumbnails)
    thumbnails.each do |thumb|
      Thumbnail.create({:image => File.open(thumb),
                        :video_clip_id => @video_clip.id,
                        :main_thumbnail => false
                       })
    end
  end

  #On vérifie l'accès au controller à chaque action!
  def verify_access_video(video_clip, current_action)
    case current_action
      #Pour l'action show.
      #L'administrateur ou la personne qui a chargé la vidéo peut accéder au contenu
      #Si la personne qui demande voir la vidéo n'est pas administrateur ni propriétaire
      #alors on vérifie si cette personne appartient à un groupe qui a accès à la vidéo et
      #ensuite si la vidéo est disponible.
      #Si un des cas n'est pas respecté alors une page de "non permission" est affichée
      when 'show'
        if current_person.type != 'Admin' && !current_person_is_video_owner?(video_clip)
          if !current_person_video_groups_present?(video_clip)
            respond_to do |format|
              format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
            end
          else
            if !video_clip.is_available?
              respond_to do |format|
                format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
              end
            end
          end
        end
      #Pour l'action edit. Seule les personnes qui ont des droits
      #sur la vidéo peuvent la modifier. Typiquement l'Administrateur
      #et la personne qui a chargé la vidéo
      when 'edit'
        if(current_person.type != 'Admin' && !(current_person_is_video_owner?(video_clip)))
          respond_to do |format|
            format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
          end
        end
      #Pour charger une vidéo. On vérifie si l'utilisateur a le droit
      #de faire un chargement. Pour cela on vérifie, tout d'abord, les droits associés
      #à son groupe personal et ensuite les droits associés à un group
      when 'new'
        if current_person.type != 'Admin'
          if !(right_in_current_person_personalgroup?('Upload'))
            if !(current_person_groups_enable?)
              respond_to do |format|
                format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
              end
            else
              if !(right_in_current_person_groups?('Upload'))
                respond_to do |format|
                  format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
                end
              end
            end
          end
        end
      #Pour effacer une vidéo. On vérifie si un utilisateur peut effacer la vidéo
      #concernée
      when 'delete'
        if current_person.type != 'Admin'
          if !(current_person_is_video_owner?(video_clip))
            respond_to do |format|
              format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
            end
          end
        end
    end
  end
end
