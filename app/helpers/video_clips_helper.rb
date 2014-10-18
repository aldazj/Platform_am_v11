#####################################
# Aldaz Jayro               HEPIA
#
#####################################

module VideoClipsHelper

  #On vérifie si la vignette passé en paramètre est
  #selectionnée pour représenter la vidéo
  def thumbnail_selected?(thumbnail)
    @thumbnail = Thumbnail.find(thumbnail)
    return @thumbnail.main_thumbnail
  end

  #On vérifie si le groupe a le droit de voir la vidéo
  def video_clip_group_present?(videoclip, group)
    !(videoclip.groups.find_by_id(group.id).nil?)
  end

end
