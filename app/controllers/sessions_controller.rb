#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#On inclut le helper session avec ces functions definies
include SessionsHelper

class SessionsController < ApplicationController

    #ON vérifie si un personne a une session
    def new
        if signed_in?
          redirect_to video_clips_path
        else
          render 'new'
        end
    end

    #On récupère les informations entrées par un utilisateur
    #comme pseudo et son mot de passe (Authentification)
    #Si les information sont juste on connecte la personne
    def create
       person = Person.find_by_email(params[:session][:email])
       if person && person.authenticate(params[:session][:password])
           sign_in person
           if session[:return_to].nil?
             #Si on n'a pas envoyé un URL pour voir une video, alors
             #On va dans la page initiale où il y a toutes les vidéos
             redirect_to video_clips_path
           else
             #Si on a envoyé un URL pour voir une video, alors
             #On fait une redirection sur la video
             redirect_back
           end
       else
           flash.now[:error] = 'Invalid email or password'
           render 'new'
       end
    end

    #On déconnecte une personne de sa session
    def destroy
        #disconnect a person
        sign_out
        #display loggin page
        redirect_to signin_path
    end
end
