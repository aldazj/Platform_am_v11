#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class Comment < ActiveRecord::Base
  #On inclut PublicActivity pour faire un control de cette activité manuellement
  include PublicActivity::Common
  # tracked except: :update, owner: ->(controller, model) { controller && controller.current_user }

  #Associations
  belongs_to :person
  belongs_to :video_clip

end
