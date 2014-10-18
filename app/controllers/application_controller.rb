#####################################
# Aldaz Jayro               HEPIA
#
#####################################

#Classe qui est disponible dans tout notre système

class ApplicationController < ActionController::Base

  #Inclut le module PublicActivity et le mets visible par tous les autres objets
  include PublicActivity::StoreController

  protect_from_forgery with: :exception

  #Inclut les methodes qui se trouve dans le fichier helper session
  include SessionsHelper
  #On protège l'action current person qui se trouve dans helper session (sécurité session)
  hide_action :current_person

  #Modifie la variable qui se charge de définir la langue.
  before_filter :set_locale

  private
    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale if signed_in?
      if params[:locale] == 'en?locale=en'
        I18n.locale = 'en'
      elsif params[:locale] == 'fr?locale=fr'
        I18n.locale = 'fr'
      end

      #Ajoute par la langue utilisée dans chaque URL
      Rails.application.routes.default_url_options[:locale]= I18n.locale
    end

end
