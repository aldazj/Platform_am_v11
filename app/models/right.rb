#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class Right < ActiveRecord::Base

  #On inclut PublicActivity pour enregistrer les activitées par rapport à ce modèle
  include PublicActivity::Model
  tracked except: :update, owner: ->(controller, model) { controller && controller.current_person }

  #Associations
  has_and_belongs_to_many :groups, :join_table => 'groups_rights'
  has_and_belongs_to_many :personalgroups, :join_table => 'personal_groupsrights'

  #Validateurs
  validates :name, presence: true
end
