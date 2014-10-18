#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#http://thewebfellas.com/blog/2009/8/29/protecting-your-paperclip-downloads
class VideoClip < ActiveRecord::Base

  #On inclut PublicActivity pour enregistrer les activitées par rapport à ce modèle
  include PublicActivity::Model
  tracked except: :update, owner: ->(controller, model) { controller && controller.current_person }

  #On inclut les librairies ruby utilisées
  require 'digest/md5'

  #Associations
  belongs_to :person

  has_many :thumbnails, :dependent => :destroy
  accepts_nested_attributes_for :thumbnails, :allow_destroy => true

  has_many :formatvideos, :dependent => :destroy
  accepts_nested_attributes_for :formatvideos, :allow_destroy => true

  has_many :comments, :dependent => :destroy
  accepts_nested_attributes_for :comments, :reject_if => lambda { |attribute| attribute[:message].blank?}, :allow_destroy => true

  has_and_belongs_to_many :groups, :join_table => 'groups_video_clips'

  #On configure Paperclip et on l'associe à ce modèle
  has_attached_file :videoitemclip,
                    #:preserve_files => true,  #Décommenter si on veut le effacement logique
                    :storage => :s3,
                    :s3_credentials => "#{Rails.root}/config/s3.yml",
                    :bucket => '**********',
                    :s3_host_name => 's3-us-west-2.amazonaws.com',
                    :path => ':class/:attachment/:token/:style/:basename.:extension'

  #Décommenter si on veut l'éffacement logique
  #acts_as_paranoid

  #Validateurs
  validates_presence_of :title, presence: true, allow_blank: false
  validates_presence_of :token

  after_initialize :init, :before_validation_on_create

  #On ajoute des validateurs pour notre paperclip videoitemclip
  validates_attachment_content_type :videoitemclip,
                                    :content_type =>
                                        [ "application/x-mp4",
                                          "video/mpeg",
                                          "video/quicktime",
                                          "video/x-la-asf",
                                          "video/x-ms-asf",
                                          "video/x-msvideo",
                                          "video/x-sgi-movie",
                                          "video/x-flv",
                                          "flv-application/octet-stream",
                                          "video/3gpp",
                                          "video/3gpp2",
                                          "video/3gpp-tt",
                                          "video/BMPEG",
                                          "video/BT656",
                                          "video/CelB",
                                          "video/DV",
                                          "video/H261",
                                          "video/H263",
                                          "video/H263-1998",
                                          "video/H263-2000",
                                          "video/H264",
                                          "video/JPEG",
                                          "video/MJ2",
                                          "video/MP1S",
                                          "video/MP2P",
                                          "video/MP2T",
                                          "video/mp4",
                                          "video/MP4V-ES",
                                          "video/MPV",
                                          "video/mpeg4",
                                          "video/mpeg4-generic",
                                          "video/nv",
                                          "video/parityfec",
                                          "video/pointer",
                                          "video/raw",
                                          "video/rtx"]


  #On récupère le token associé à ce modèle
  #Ce token est utilisée pour sécuriser l'URL de la vidéo
  def to_param
    token
  end

  #On ajoute le groupe qui peut voir la vidéo
  def add_group(group)
    groups << group
  end

  def generate_video_suggest_token
    generate_token(:video_suggest_token)
    self.video_suggest_token_sent_at = Time.zone.now
    save!
  end

  protected

  #On génère le token pour sécuriser L'URL de la vidéo
  #Pour cela, on utilise l'algorithme de cryptage MD5 sur la date actuelle et un nombre très grand généré.
  def before_validation_on_create
    self.token = Digest::MD5.hexdigest(Time.now.strftime("%Y-%d-%m %H:%M:%S %Z").to_s+" "+rand(36**10).to_s(36)) if self.new_record? and self.token.nil?
  end

  private

    #Par défault on met une vidéo disponible
    def init
      if self.new_record? && self.videoclip_from_url.nil?
        self.is_available = true
      end
    end

    #On cherche une vidéo disponible ou une video qui nous appartient
    def self.search_video(search_video, current_person)
      if current_person.type == 'Admin'
        search(search_video)
      else
        if !(current_person.groups.nil?)
          video_clips_tmp = Array.new
          groups_tmp = current_person.groups
          if search_video
            where('title LIKE ?', "%#{search_video}%")
          else
            videos_tmp = where('is_available LIKE ? OR person_id = ?', true, current_person.id)
            videos_tmp.each do |video|
              groups_tmp.each do |group|
                if !(video.groups.find_by_id(group.id).nil?)
                  video_clips_tmp << video
                end
              end
            end
            video_clips_tmp.map{|i| i.id}
            @video_clips = VideoClip.where(:id => video_clips_tmp)
          end
        end
      end
    end

    #On cherche une vidéo indisponible
    def self.search_video_unavailable(search_video_unavailable, current_person)
      if search_video_unavailable
        where('title LIKE ?', "%#{search_video_unavailable}%")
      else
        if current_person.type == 'Admin'
          where('is_available LIKE ?', false)
        end
      end
    end

    #on cherche une vidéo spécifique.
    def self.search(search_video)
      if search_video
        where('title LIKE ?', "%#{search_video}%")
      else
        self.all
      end
    end

    #On crée un token pour n'importe quelle colonne passée en paramètre
    def generate_token(column)
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while VideoClip.exists?(column => self[column])
    end
end
