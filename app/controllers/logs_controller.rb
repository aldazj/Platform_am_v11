#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class LogsController < ApplicationController
  #Filtres
  before_filter :signed_in_person
  before_filter :verify_access

  #On affiche les logs du serveur selon l'environement de Rails (Production/Developement)
  def index
    lines = params[:lines]
    if Rails.env == "production"
      @logs = `tail -n #{lines} log/production.log`
    else
      @logs = `tail -n #{lines} log/development.log`
    end
  end

  private

  def signed_in_person
    redirect_to signin_path, notice: 'Please sign in.' unless signed_in?
  end

  #Verification de l'accès au controller
  def verify_access
    if !(current_person.nil?)
      if current_person.type != 'Admin'
        respond_to do |format|
          format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
        end
      end
    else
      respond_to do |format|
        format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
      end
    end
  end
end
