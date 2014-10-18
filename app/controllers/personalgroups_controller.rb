#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class PersonalgroupsController < ApplicationController
  #Filtres
  before_action :set_personalgroup, only: [:show, :edit, :update, :destroy]
  before_filter :signed_in_person
  before_filter :verify_access

  # GET /personalgroups
  # GET /personalgroups.json
  def index
    @personalgroups = Personalgroup.all
  end

  # GET /personalgroups/1
  # GET /personalgroups/1.json
  def show
  end

  # GET /personalgroups/new
  def new
    @personalgroup = Personalgroup.new
  end

  # GET /personalgroups/1/edit
  def edit
  end

  # POST /personalgroups
  # POST /personalgroups.json
  def create
    @personalgroup = Personalgroup.new(personalgroup_params)

    respond_to do |format|
      if @personalgroup.save
        format.html { redirect_to @personalgroup, notice: 'Personalgroup was successfully created.' }
        format.json { render action: 'show', status: :created, location: @personalgroup }
      else
        format.html { render action: 'new' }
        format.json { render json: @personalgroup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /personalgroups/1
  # PATCH/PUT /personalgroups/1.json
  def update
    respond_to do |format|
      if @personalgroup.update(personalgroup_params)
        format.html { redirect_to @personalgroup, notice: 'Personalgroup was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @personalgroup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /personalgroups/1
  # DELETE /personalgroups/1.json
  def destroy
    @personalgroup.destroy
    respond_to do |format|
      format.html { redirect_to personalgroups_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_personalgroup
      @personalgroup = Personalgroup.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def personalgroup_params
      params.require(:personalgroup).permit(:person_id, rights_attributes: [:id, :name, :is_available, :right_ids])
    end

    #Vérifie si la personne est connectée
    def signed_in_person
      redirect_to signin_path, notice: 'Please sign in.' unless signed_in?
    end

    #On vérifie l'accès au controller.
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
