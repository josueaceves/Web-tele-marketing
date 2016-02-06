class UsersController < ApplicationController
	 
	def new
		@user = User.new
	end

	def show
		p params
		@user = current_user(params[:id])
	end

	def create
		@user = User.new(user_params)
		if @user.save
			redirect_to '/'
		else
			@errors = @user.errors.full_messages
			render 'new'
		end
	end


	private 
	def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password)
  end

end