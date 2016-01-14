
class SessionsController < ApplicationController
  
  def new
  end

  def create
  	user = User.find_by(email: session_params[:email])
    if user && user.authenticate(session_params[:password])
      session[:user_id] = user.id
      redirect_to  '/'
    else
      render 'new'
    end
  end

  def delete
  	session.delete(:user_id)
  	redirect_to "/"
  end


  private
  def session_params
    params.require(:user).permit(:email, :password)
  end
end


