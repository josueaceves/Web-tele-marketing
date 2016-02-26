class UsersController < ApplicationController

	def new
		@user = User.new
	end

	def show
		@user = current_user
	end

	def create
		@user = User.new(user_params.merge(user_number))
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

	def user_phone
		params.require(:phone).permit(:area, :pre, :body)
	end

	def user_number
		{number: "#{user_phone[:area]}#{user_phone[:pre]}#{user_phone[:body]}"}
	end

end
