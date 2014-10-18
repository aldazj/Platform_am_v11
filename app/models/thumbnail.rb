#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class Thumbnail < ActiveRecord::Base

  #Association
  belongs_to :videoClip


  #On configure Paperclip et on l'associe à ce modèle
  has_attached_file :image,
                    :styles =>{:medium => '640x480>',
                               :thumb => '100x100#'
                               },
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :bucket => '**********',
                    :s3_host_name => 's3-us-west-2.amazonaws.com',
                    :path => ':class/:attachment/:id/:style/:basename.:extension'

  #Validateurs
  validates_attachment :image, presence: true, content_type: { content_type: ["image/png", "image/jpeg", "image/jpg", "image/gif"] }
  #validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }

  #On appèle la fonction init
  after_initialize :init

  private

    #Par défault on met que la vignette n'est pas séléctionnée pour
    #représenter une vidéo
    def init
      if self.new_record? && self.main_thumbnail.nil?
        self.main_thumbnail = false
      end
    end
end
