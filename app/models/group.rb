#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class Group < ActiveRecord::Base

    #On inclut PublicActivity pour enregistrer les activitées par rapport à ce modèle
    include PublicActivity::Model
    tracked except: :update, owner: ->(controller, model) { controller && controller.current_person }

    #Associations
    has_and_belongs_to_many :rights, :join_table => 'groups_rights'
    has_and_belongs_to_many :people, :join_table => 'groups_people'
    has_and_belongs_to_many :video_clips, :join_table => 'groups_video_clips'

    #Validateurs
    validates :name, presence: true

    #Fonction qui ajoute un droit aux droits d'un groupe
    def add_right(right)
        rights << right
    end

  private

    #Fonction qui cherche un groupe précis
    def self.search(search_group)
      if search_group
        where('name LIKE ?', "%#{search_group}%")
      else
        self.all
      end
    end
end
