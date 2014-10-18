#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class PeopleController < ApplicationController
  #Filtres
  before_action :set_person, only: [:show, :edit, :update, :destroy]
  before_filter :signed_in_person, only: [:index, :edit, :update]
  before_filter :verify_access
  #before_filter :correct_person, only: [:edit, :update]

  #On utilise les functions qui se trouvent dans people helper
  #Ces functions permettent de ordonner la liste des utilisateurs dans l'ordre
  #alphabétique
  helper_method :sort_column, :sort_direction


  #Le parametre q (moyen de faire récupère ce qu'un utilisateur entre) est definit dans la librarie tokeninput
  #Lire cette documentation pour comprendre http://loopj.com/jquery-tokeninput/
  # GET /people
  # GET /people.json
  def index
    #@people = Person.all
    case params[:type]
      when 'admin'
            #@people = Admin.all
            @people = Person.search(params[:q]).order(sort_column + " " + sort_direction).paginate(:per_page => 7, :page => params[:page])
      when 'user'
            #@people = User.all
            @people = Person.search(params[:q]).order(sort_column + " " + sort_direction).paginate(:per_page => 7, :page => params[:page])
      when 'person'
            @people = Person.search(params[:q]).order(sort_column + " " + sort_direction).paginate(:per_page => 7, :page => params[:page])
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    @person = Person.find(params[:id])
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
    @person = Person.find(params[:id])
  end

  # POST /people
  # POST /people.json
  def create
    case params[:type]
        when 'admin'
            @person = Admin.new(person_params)
        when 'user'
            @person = User.new(person_params)
        when 'person'
            @person = Person.new(person_params)
    end

    # On vérifie qu'une personne n'appartient à aucun groupe
    @person.groups.clear
    params[:person][:group_ids] ||= []

    #On attribue à une personne différents groupes choisis un utilisateur
    params[:person][:group_ids].each do |group|
        if !(group.blank?)
            @person.add_group(Group.find_by_id(group))
        end
    end

    #Important de créer capitalize le nom complet
    #Car cette variable sera utilisé par faire la autocompletion
    #pour le champ Users dans nos mails.
    lastname = @person.lastname.capitalize
    firsname = @person.firstname.capitalize
    @person.name = lastname+' '+firsname

    respond_to do |format|
      if @person.save

        #Une fois qu'on a enregistré une personne.
        #On crée son groupe personnel.
        if @person.personalgroup.nil?
            Personalgroup.create(person_id: @person.id)
        end

        #On envoie un mail à la personne qui vient être enregistrée
        PersonMailer.registration_mail(@person).deliver

        format.html { redirect_to @person, notice: t('person.created_msg') }
        format.json { render action: 'show', status: :created, location: @person }
      else
        format.html { render action: 'new' }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    @person = Person.find(params[:id])

    #Il y a que les administrateurs qui peuvent modifer les groupes
    #d'une personne
    if current_person.type == 'Admin'
      # On s'assure que les groups d'une personne sont vides
      @person.groups.clear
      #On mets à jours les groupes qu'il faut attribuer à une personne
      params[:person][:group_ids] ||= []
      params[:person][:group_ids].each do |group|
        if !(group.blank?)
          @person.add_group(Group.find_by_id(group))
        end
      end

      # On met à jour le groupe personnel d'une personne
      personalGroup = Personalgroup.find_by_person_id(@person)
      personalGroup.rights.clear

      #On met à jour ce groupe personnel en ajoutant les droits qu'on l'a attribué.
      params[:personalgroup][:right_ids] ||= []
      params[:personalgroup][:right_ids].each do |right|
        if !(right.blank?)
          personalGroup.add_right_to_personalgroup(Right.find_by_id(right))
        end
      end
    end

    respond_to do |format|
      if current_person?(@person)
        if @person.update(person_params)
          sign_out
          format.html { redirect_to root_path, :notice => 'Please sign in'}
        else
          format.html { render action: 'edit'}
          format.json { render json: @person.errors, status: :unprocessable_entity }
        end
      else
        if @person.update(person_params)
          #On met à jour "name". Champ utilisé pour l'autocompletion.
          if current_person.type == 'Admin'
            lastname = @person.lastname.capitalize
            firsname = @person.firstname.capitalize
            @person.name = lastname+' '+firsname
            @person.save!
          end
          format.html { redirect_to @person, notice: t('person.updated_msg') }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @person.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    #On crée la bonne instance souhaitée
    def person_params
      if params[:admin] != nil
          params.require(:admin).permit(:lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :password, :password_confirmation,:type, :name,
                                         videoitems_attributes: [:id, :title, :description, :is_available, :date, :views, :pathvideo, :_destroy])
      elsif params[:user] != nil
          params.require(:user).permit(:lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :password, :password_confirmation, :type, :name,
                                         videoitems_attributes: [:id, :title, :description, :is_available, :date, :views, :pathvideo, :_destroy])
      elsif params[:person] != nil
          params.require(:person).permit(:lastname, :firstname, :email, :dateofbirth, :private_phone, :professional_phone, :password, :password_confirmation, :type, :name,
                                         videoitems_attributes: [:id, :title, :description, :is_available, :date, :views, :pathvideo, :_destroy])
      end
    end

    #Vérifie si une personne est connectée
    def signed_in_person
      redirect_to signin_path, notice: 'Please sign in.' unless signed_in?
    end

    #Vérfie si la personne connectée est la bonne
    def correct_person
        @person = Person.find(params[:id])
        redirect_to signin_path unless current_person?(@person)
    end

    #Vérifie l'acess au controller
    def verify_access
        if !(current_person.nil?)
          if current_person.type != 'Admin'
            if !(current_person?(@person))
              respond_to do |format|
                format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
              end
            end
          end
        else
          respond_to do |format|
            format.html { render :file => "#{Rails.root}/public/422.html", :status => :unprocessable_entity, :layout => false }
          end
        end
    end

    #Functions utilisée pour ordonné les colonnes de la liste qui se trouve à la page index du modèle
    #person dans ordre alphabétique
    def sort_column
      Person.column_names.include?(params[:sort]) ? params[:sort] : "lastname"
    end

    def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
