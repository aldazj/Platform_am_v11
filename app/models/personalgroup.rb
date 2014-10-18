#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class Personalgroup < ActiveRecord::Base

  #Associations
  belongs_to :person
  has_and_belongs_to_many :rights, :join_table => 'personal_groupsrights'

  #On ajoute un droit dans un groupe personnel
  def add_right_to_personalgroup(right)
      self.rights << right
  end
end
