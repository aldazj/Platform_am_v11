#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class VideoClipStepsController < ApplicationController

  #On inclut la librarie Wicked
  include Wicked::Wizard

  #On définit les différents états qu'on va faire passer notre element video clip
  #L'ordre est important
  steps :thumbnail_page, :select_thumbnail_page

  #On affiche à chaque étape notre modèle video clip
  def show
    @video_clip = VideoClip.find(params[:video_clip_id])
    case step
      when :thumbnail_page
        #Pour permettre ajouter des vignettes supplémentaires à notre model video clip
        @video_clip.thumbnails.build
    end
    render_wizard
  end

  #A chauqe étape on met à jour notre modèle video clip et tous les autres tables qui
  #intéragissent avec ce dernier. Par example la table Thumbnail
  def update
      @video_clip = VideoClip.find(params[:video_clip][:video_clip_id])

      case step
      when :thumbnail_page
          if @video_clip.update_attributes(video_clip_params)
             redirect_to wizard_path(:select_thumbnail_page, :video_clip_id => @video_clip.id), notice: 'Videoclip was successfully upload.'
          end
      when :select_thumbnail_page
          #On met à true la vignette selectionnée pour représenter notre video clip.
          #Les autres vignettes sont à faux.
          select_thumbnail = 0
          @video_clip.thumbnails.each do |thumbnail|
              if thumbnail.id == params[:main_thumbnail].to_i
                thumbnail.main_thumbnail = true
                select_thumbnail += 1
              else
                thumbnail.main_thumbnail = false
              end
          end

          #Vérifie si on a choisi une vignette pour finir le processus qui
          #met à jour la table de notre modèle petit à petit.
          if select_thumbnail == 1
            if @video_clip.update_attributes(video_clip_params)
              redirect_to_finish_wizard
            end
          else
            redirect_to wizard_path(:select_thumbnail_page, :video_clip_id => @video_clip.id)
          end
      end
  end

  private
    #On vérifie si tous les paramètres obligatoires sont présents
    def video_clip_params
      params.require(:video_clip).permit(:title, :description, :is_available, :date, :views, :videoitemclip, :videoclip_from_url,
                                         thumbnails_attributes: [:id, :image, :main_thumbnail, :_destroy],
                                         formatvideos_attributes: [:id, :format, :_destroy])
    end

    #Quand on a fini le processus wicked, on va à la page principal où on trouve tous les video clips
    def redirect_to_finish_wizard
      respond_to do |format|
          format.html { redirect_to video_clips_path, notice: 'Videoitem was successfully created.'}
      end
    end

end
