#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class SendvideosController < ApplicationController
  #Ici on va utiliser la librarie tokeninput.
  #Dans la librarie tokeninput, tout ce qu'un utilisateur entre, est stocké dans
  #le parametre q!
  #Lire cette documentation pour comprendre http://loopj.com/jquery-tokeninput/

  def index
    verify_access_sendvideos('index')
    @groups = Group.search(params[:q])
    @people = Person.search(params[:q])
    @video_clips = VideoClip.search(params[:q])
  end


  #Une fois qu'on a mis un élément dans le textfield qui fait l'autcompletion
  #ces éléments sont stockées dans une liste. Chaque élément dans cette liste est séparé
  #par une virgule.
  #On recupère toutes ces listes et on traite les mails
  def create
    mails = Array.new
    videos = Array.new
    groupsActiveRecord = Array.new
    dests_ActiveRecord = Array.new
    subject = params[:subject]
    groups_ids = params[:groups_tokens]
    users_ids = params[:users_tokens]
    videos_ids = params[:videos_tokens]
    message = params[:message_email]
    mails = getMails(groups_ids, users_ids, mails)
    videos = getVideos(videos_ids, videos)

    #Générer un token d'accès pour toutes les vidéos suggérées.
    #Quand on ajoute une vidéo à la plate-forme on lui attribue les groupes qui ont accès
    #à son contenu.
    #Quand on suggère des vidéos, on ne doit pas se soucier si la personne, à qui est destinée le mail,
    #appartient ou pas à un groupe qui a accès au contenu vidéo.
    #Le token permet à n'importe quel utilisateur de la plate-forme d'accéder, pendant une période, à la vidéo.
    if !(videos.empty?)
      generate_access_email_tokens(videos)
    end

    if !(mails.empty?)
      #On envoie les mails
      mails.each do |mail|
        PersonMailer.send_video(subject, mail, videos, message).deliver
      end

      #Si on suggère des vidéos alors on enregistre l'activité
      if !(videos.empty?)
        groupsActiveRecord = getGroups(groups_ids, groupsActiveRecord)
        dests_ActiveRecord = getDests(users_ids, dests_ActiveRecord)
        record_sendvideo_activity(videos, groupsActiveRecord, dests_ActiveRecord)
      end

    else
      redirect_to sendmail_path, :notice => t('sendmail.msg_add_recipients')
    end
  end


  def show
    @video_clip = VideoClip.find_by_video_suggest_token(params[:id])

    if @video_clip
      #Ici on donne 1 heure d'accès à la vidéo
      if Time.zone.now > @video_clip.video_suggest_token_sent_at + 1.hours
        video_suggest('link_video_suggest_expired')
      else
        video_suggest('link_video_suggest_available')
      end
    else
      video_suggest('link_video_suggest_expired')
    end
  end

  private
    #À partir du nom de la vidéo qu'on veut suggéré, on récupère son URL.
    def getVideos(videos_ids, videosActive)
      videos_list = getElementArray(videos_ids)
      if !(videos_list.nil?)
        videos_list.each do |video|
          videoActiveRecord = VideoClip.find_by_id(video.lstrip.to_i)
          videosActive << videoActiveRecord
        end
      end
      return videosActive
    end

    #On envoie une liste avec tous les mails destinataires
    def getMails(groups, users, mails)
      mails = getGroupsMails(groups, mails)
      mails = getUsersMails(users, mails)
      mails = mails.uniq
      return mails
    end

    #On récupère les mails de la liste Users
    def getUsersMails(users, mails)
      users_list = getElementArray(users)
      if !(users_list.nil?)
        users_list.each do |user|
          userActiveRecord = Person.find_by_id(user.lstrip.to_i)
          mails << userActiveRecord.email
        end
      end
      return mails
    end

    #On récupère les mails de la liste Groups
    #Pour chaque groupe, on récupere les personnes qui appartiennent à ce groupe.
    #Ensuite on envoie un mail à chaque personne.
    def getGroupsMails(groups, mails)
      groups_list = getElementArray(groups)
      if !(groups_list.nil?)
        groups_list.each do |group|
          groupActiveRecord = Group.find_by_id(group.lstrip.to_i)
          groupActiveRecord.people.each do |user|
            userActiveRecord = Person.find(user)
            mails << userActiveRecord.email
          end
        end
      end
      return mails
    end

    #On récupère les groupes à qui on envoie la vidéo
    def getGroups(groups_ids, groupsActiveRecord)
      groups_list = getElementArray(groups_ids)
      if !(groups_list.nil?)
        groups_list.each do |group|
          groupActiveRecord = Group.find_by_id(group.lstrip.to_i)
          groupsActiveRecord << groupActiveRecord
        end
      end
      return groupsActiveRecord
    end

    #On récuère les utilisateurs à qui on envoie la vidéos
    def getDests(users_ids, dests_ActiveRecord)
      users_list = getElementArray(users_ids)
      if !(users_list.nil?)
        users_list.each do |user|
          userActiveRecord = Person.find_by_id(user.lstrip.to_i)
          dests_ActiveRecord << userActiveRecord
        end
      end
      return dests_ActiveRecord
    end

    #On separe les éléments trouvés dans le textfield qui fait l'autocompletion
    #Rappel ces elements sont séparés par de virgules. Voir API (http://loopj.com/jquery-tokeninput/)
    def getElementArray(elements)
      if !(elements.empty?)
        return elements.split(',')
      end
      return nil
    end

    #Généré un token d'accès temporaire pour chaque vidéo suggérée
    def generate_access_email_tokens(videos)
      videos.each do |video|
        #Si la vidéo n'a jamais a été suggérée, alors on crée un token pour
        #accéder au contenu
        if video.video_suggest_token.nil?
          video.generate_video_suggest_token if video
        else
          #Si la vidéo possède déjà un token d'accès (vidéo a déjà été suggérée à des utilisateurs)
          #On vérifie la validité du token.
          #Si 1 jour est passé depuis la dernière fois qu'un token a été créé,
          #alors on génère un nouveau.
          #--------------
          #if Time.zone.now > video.video_suggest_token_sent_at + 1.days
          #--------------

          #Si ca fait 6 heures que le lien de la video n est pas active, on generete un nouveau lien
          if Time.zone.now > video.video_suggest_token_sent_at + 6.hours
            video.generate_video_suggest_token if video
          end
        end
      end
    end

    #On vérifie si le lien de la vidéo est disponible ou pas.
    def video_suggest(msg)
      case msg
        when 'link_video_suggest_expired'
          signed_in_person('link_expired')
        when 'link_video_suggest_available'
          signed_in_person('link_available')
      end
    end

    #On vérifie si la personne est connectée
    def signed_in_person(msg)
      if signed_in?
        case msg
          when 'link_expired'
            redirect_to root_url, :notice => 'Sorry, The link to access to the suggest video has expired'
          when 'link_available'
            @video_clip.increment!(:views)
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
      else
        #On stocke l'URL de la vidéo que l'utilisateur veut voir
        store_location
        #On lui oblige à s'authentifier et on prepare le msg à lui montrer
        redirect_to signin_path, :notice => 'Please sign in'
      end
    end

    #On enregistre l'activité seulement quand on suggère des vidéos
    def record_sendvideo_activity(videos, groupsActiveRecord, dests_ActiveRecord)
      if !(videos.empty?)
        videos.each do |video|

          if !(groupsActiveRecord.empty?)
            groupsActiveRecord.each do |group_dest|
              video.create_activity :sendvideo, owner: current_person, recipient: group_dest
            end
          end

          if !(dests_ActiveRecord.empty?)
            dests_ActiveRecord.each do |user_dest|
              video.create_activity :sendvideo, owner: current_person, recipient: user_dest
            end
          end
        end
      end
    end

      #On vérifie l'accès au controller.
    def verify_access_sendvideos(current_action)
      case current_action
        when 'index'
          if !(current_person.nil?)
            if current_person.type != 'Admin'
              respond_to do |format|
                format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
              end
            end
          else
            respond_to do |format|
              format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
            end
          end
      end
    end
end
