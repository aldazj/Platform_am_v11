#####################################
# Aldaz Jayro               HEPIA
#
#####################################


class ActivitiesController < ApplicationController
  #Filtres
  before_filter :signed_in_person
  before_filter :verify_access


  #On récupère toutes les activitées
  def index
    #PublicActivity::Activity nous retourne un ActiveRecord model
    #où on peut appliquer toutes les notions de rails sur un model
    @activities = PublicActivity::Activity.order('created_at desc')
  end

  #Pour effacer la liste qui possède toutes les activités
  #Cette fonction est crée dans le but de vider la table activités.
  def remove_all
    @activities = PublicActivity::Activity.all
    @activities.each do |activity|
      activity.destroy
    end
    flash[:notice] = t('activity.meg_remove_activities')
    redirect_to activities_path
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
