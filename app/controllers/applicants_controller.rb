class ApplicantsController < ApplicationController
    before_action :set_applicant, only: [:show, :edit, :update, :destroy]
    before_action :require_user2, only: [:edit, :update]
    before_action :req_same_applicant, only: [:edit, :update, :delete]
    def new
        @applicant= Applicant.new
    end
    def index
        @applicants= Applicant.paginate(page: params[:page], per_page: 4)
    end
    def show
        if !logged_in? && !logged2_in?
            flash[:alert] = "Login before you see applicant Profiles"
            redirect_to login_path
        end    
    end
    def edit 
    end

    def update
        if @applicant.update( applicant_params )
            skill_match @applicant, 'update' 
            flash[:notice]= 'Your User profile Information Updated Scuccesfully'
            skill_match @applicant, 'update'
            redirect_to applicant_path(@applicant)
        else
            flash[:alert]= "You can only edit your company profile"
            render 'edit'
        end
    end

    def create
        @applicant = Applicant.new(applicant_params)
        if @applicant.save
            session[:user2_id] = @applicant.id
            NotificationMailer.create_action(@applicant).deliver_now
            skill_match @applicant, 'create' 
            flash[:notice] = "Welcome to Catalogue Ally #{@applicant.name}, you have succesfully signed up"
            redirect_to @applicant
        else
            render 'new'
        end
    end  
    def destroy
        @applicant = Applicant.find(params[:id])        
        session[:user2_id] =nil if @applicant == current_user2
        NotificationMailer.delete_action(@applicant).deliver_now
        @applicant.destroy
        respond_to do |format|
            format.html { redirect_to applicants_path notice: 'User Account is successfully deleted.' }
            format.json { head :no_content }
        end
    end

    private

    def applicant_params
        params.require(:applicant).permit(:name, :email, :password, skills: [])
    end
    def set_applicant
        if Applicant.where(id: params[:id]) != []
            @applicant= Applicant.find(params[:id])
        else 
            flash[:alert]= "User deleted his profile. Reload for updated list"
            redirect_back_or_to '/' 
        end
    end
    def req_same_applicant
        if current_user2 != @applicant 
            flash[:alert] = "You can only edit your Company profile"
            redirect_to @applicant
        end
    end

end
