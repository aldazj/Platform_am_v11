#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class PasswordResetsController < ApplicationController

  def new
  end

  #On envoie un lien pour modifier son mot de passe si la personne est
  #enregistrée dans la plate forme vidéo
  #Le lien est temporaire
  def create
    person = Person.find_by_email(params[:email])
    person.send_password_reset if person
    redirect_to root_url, :notice => "Email sent with password reset instructions."
  end

  def edit
    @person = Person.find_by_password_reset_token!(params[:id])
  end

  #Le lien envoyé pour modifier un mot de passe est valable pendant 2 heures
  def update
    @person = Person.find_by_password_reset_token!(params[:id])
    if Time.zone.now > @person.password_reset_sent_at + 3.minutes
      redirect_to new_password_reset_path, :notice => "Password reset has expired. Ask to reset your password again"
    elsif @person.update_attributes(person_params)
      redirect_to root_url, :notice => "Password has been reset. Enter your new password"
    else
      render :edit
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  #On met à jour le bon modèle
  def person_params
    if params[:admin] != nil
      params.require(:admin).permit(:lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :password, :password_confirmation,:type,
                                    videoitems_attributes: [:id, :title, :description, :is_available, :date, :views, :pathvideo, :_destroy])
    elsif params[:user] != nil
      params.require(:user).permit(:lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :password, :password_confirmation, :type,
                                   videoitems_attributes: [:id, :title, :description, :is_available, :date, :views, :pathvideo, :_destroy])
    elsif params[:person] != nil
      params.require(:person).permit(:lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :password, :password_confirmation, :type,
                                     videoitems_attributes: [:id, :title, :description, :is_available, :date, :views, :pathvideo, :_destroy])
    end
  end
end
