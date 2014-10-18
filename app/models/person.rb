#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class Person < ActiveRecord::Base

    #On inclut PublicActivity pour enregistrer les activitées par rapport à ce modèle
    include PublicActivity::Model
    tracked except: :update, owner: ->(controller, model) { controller && controller.current_person }

    #Associations
    has_and_belongs_to_many :groups, :join_table => 'groups_people'

    has_many :video_clips, :dependent => :destroy
    accepts_nested_attributes_for :video_clips, :allow_destroy => true

    has_one :personalgroup, :dependent => :destroy

    has_many :comments

    #Utilisation du gem bcrypt-ruby est ces fonctionnes des cryptage
    has_secure_password

    #Definition de types pour créer un STI (Simple table inheritance) table pour ce modèle
    TYPES = %w( Admin User )

    #On définit la bonne instance pour chaque modèle qui hérite de cet modèle Person
    before_save :set_type

    #On valide les champs importants de notre modèle
    before_save { |person| person.email = email.downcase }
    validates :lastname, presence: true, length: { maximum: 50 }
    validates :firstname, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true,
              format: { with: VALID_EMAIL_REGEX }
    validates :password_digest, presence: true, length: { minimum: 4 }, :on => :create
    validates :password_confirmation, presence: true, :on => :create
    before_save :create_remember_token


    #On ajoute un groupe à une personne
    def add_group(group)
        groups << group
    end

    #Fonction qui doit être surchargée par les autres modèles pour définir leur bonne instance
    def set_type
        raiser "override method  in each model inheriting from Person!" #Important!
    end

    #Fonction qui permet de modifier un mot de passe oublié
    #Pour cela on modifie le modèle personne pour savoir
    #si le lien envoyé pour modifier un mot de passe est encore valable ou pas.
    def send_password_reset
      generate_token(:password_reset_token)
      self.password_reset_sent_at = Time.zone.now
      save!
      PersonMailer.password_reset(self).deliver
    end

    private

        #On crée un token qui mémorise une personne. Util pour une session.
        def create_remember_token
            self.remember_token = SecureRandom.urlsafe_base64
        end

        #On crée un token pour n'importe quelle colonne d'une personne
        def generate_token(column)
          begin
            self[column] = SecureRandom.urlsafe_base64
          end while Person.exists?(column => self[column])
        end

        #On cherche une personne spécifique
        def self.search(search)
          if search
            where('name LIKE ?', "%#{search}%")
          else
            self.all
          end
        end

end
