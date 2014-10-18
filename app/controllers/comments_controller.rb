#####################################
# Aldaz Jayro               HEPIA
#
#####################################

class CommentsController < ApplicationController

  #Filtres
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_filter :signed_in_person
  before_filter :verify_access, only: [:index]

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
  end

  # GET /comments/1/edit
  def edit
  end


  #Un commentaire doit contenir du texte. Il ne peut pas être vide.
  #On recupère la video à laquelle on va assigné le commentaire.
  #Finalement on met à jour la personne qui a commenté.
  # POST /comments
  # POST /comments.json
  def create
      if !(params[:comment][:message].empty?)
        @video_clip = VideoClip.find_by_token(params[:video_clip_id])
        @comment = @video_clip.comments.new(comment_params)
        @comment.is_available = true
        @comment.date = Time.now.strftime("%Y-%d-%m %H:%M:%S %Z")
        @comment.person_id = current_person.id

        respond_to do |format|
          if @comment.save
            @comment.create_activity :create, owner: current_person
            format.html { redirect_to @video_clip, notice: 'Comment was successfully created.' }
            format.json { render action: 'show', status: :created, location: @video_clip }
            format.js
          else
            format.html { render action: 'new' }
            format.json { render json: @video_clip.errors, status: :unprocessable_entity }
          end
        end
      end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy
    @comment.create_activity :destroy, owner: current_person
    respond_to do |format|
      format.html { redirect_to comments_url }
      format.json { head :no_content }
    end
  end



  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    #Vérifie si la personne est connectée
    def signed_in_person
      redirect_to signin_path, notice: 'Please sign in.' unless signed_in?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:id, :message, :is_available, :date, :url, :video_clip_id, :owner)
    end

    #On vérifie l'accès à ce controller.
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
