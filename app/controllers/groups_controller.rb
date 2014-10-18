#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class GroupsController < ApplicationController
  #Filtres
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_filter :signed_in_person
  before_filter :verify_access

  #Dans ce partie le retour du format json est important
  #C'est le moyen par le quel le tokeninput, utilisé dans la pour l'envoie de mails,
  #récupère le groupe désiré
  #Le parametre q est necessaire dans cette librarie tokeninput
  #Lire cette documentation pour comprendre http://loopj.com/jquery-tokeninput/

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.search(params[:q])
    respond_to do |format|
      format.html
      format.json { render :json => @groups.map(&:attributes) }
    end
  end

  def management
    @groups = Group.all
  end

  #Important ici le retour d'une page javascript car c'est le moyen
  #qui permet de faire la pagination correctement
  # GET /groups/1
  # GET /groups/1.json
  def show
    @person_belong = @group.people.paginate(:per_page => 4, :page => params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    #On vérifie que la liste de droits d'un groupe est effacé
    @group.rights.clear

    #On ajoute les droits choisis par un utilisateur
    params[:group][:right_ids] ||= []
    params[:group][:right_ids].each do |right|
        if !(right.blank?)
            @group.add_right(Right.find_by_id(right))
        end
    end

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: t('group.created_msg') }
        format.json { render action: 'show', status: :created, location: @group }
      else
        format.html { render action: 'new' }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
#      debug(params[:group][:right_ids] Pour faire un debuggage dans le controlleur
      @group = Group.find(params[:id])
      @group.rights.clear

      #Mise à jour de droits que possède un groupe
      params[:group][:right_ids] ||= []
      params[:group][:right_ids].each do |right|
        if !(right.blank?)
            @group.add_right(Right.find_by_id(right))
        end
      end

      respond_to do |format|
      if @group.update(group_params)

        format.html { redirect_to @group, notice: t('group.updated_msg') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, rights_attributes: [:id, :name, :is_available, :right_ids])
    end

    #Vérifie si la personne est connectée
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
