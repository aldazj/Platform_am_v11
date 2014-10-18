#####################################
# Aldaz Jayro               HEPIA
#
#####################################

module SessionsHelper

    #Fonction qui connecte une personne
    def sign_in(person)
        # On mémorise une personne dans un cookie
        cookies.permanent[:remember_token] = person.remember_token
        # On met à jour une variable current_person qui est accéssible dans
        # toute la session
        self.current_person = person
        # Si on veut garder le cookie active pendant une certaine période seulement.
        #cookies[:login] = { value: "XJ-122", expires: 1.hour.from_now }
    end

    #Vérife si une personne est connectée dans une session
    def signed_in?
        !(current_person.nil?)
    end

    #Déconnecte une personne de sa session
    def sign_out
        #On met à null la variable global d'un session "current_person"
        self.current_person = nil
        #On efface le cookie attribué lors d'une connexion
        cookies.delete(:remember_token)
    end

    #On met à jour la variable global d'une session "current_person"
    def current_person=(person)
      @current_person = person
    end

    #On récupère une personne grâce à son cookie
    #En suite on met à jour la variable global d'une session "current_person"
    def current_person
        @current_person ||= Person.find_by_remember_token(cookies[:remember_token])
    end

    #On vérifie si la personne passé en paramètre est celle qui est connectée
    def current_person?(person)
      current_person == person
    end

    #On enregistre un URL entré par un utilisateur
    def store_location
      session[:return_to] = request.fullpath
    end

    def redirect_back
      redirect_to(session[:return_to])
      session.delete(:return_to)
    end

    #On vérifie si le droit passé en paramètre se trouve dans le groupe personel
    #de la personne connectée. On utilise le cookie
    def right_in_current_personalgroup?(right)
        @current_person ||= Person.find_by_remember_token(cookies[:remember_token])
        personalgroup = Personalgroup.find_by_person_id(@current_person.id)
        !(personalgroup.rights.find_by_name(right).nil?)
    end

    #On vérifie si le droit passé en paramètre se trouve dans le groupe personel
    #de la personne connectée. On utilise la variable global "current_person"
    def right_in_current_person_personalgroup?(right)
        personalgroup = Personalgroup.find_by_person_id(current_person.id)
        !(personalgroup.rights.find_by_name(right).nil?)
    end

    #On vérifie si une personne connectée possède des groupes
    def current_person_groups_enable?
        !(current_person.groups.nil?)
    end

    #On vérifie si la personne connectée possède, dans un
    #de ces groupes, le droit passé en paramètre.
    def right_in_current_person_groups?(right)
        available = false
        current_person.groups.each do |group|
            if group.rights.find_by_name(right)
                available = true
                return available
            end
        end
        return available
    end

    #On vérifie si la vidéo passé en paramètre appartient à la
    #personne qui est connectée
    def current_person_is_video_owner?(video_clip_tmp)
        !(current_person.video_clips.find_by_id(video_clip_tmp.id).nil?)
    end

    #On vérifie si la personne qui est connectée a le droit de voir la vidéo
    def current_person_video_groups_present?(videoclip)
      if !(videoclip.groups.nil?)
        videoclip.groups.each do |groupvideo|
          if current_person.groups.find_by_id(groupvideo.id)
            return true
          end
        end
      end
      return false
    end

end
