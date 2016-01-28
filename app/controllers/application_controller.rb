class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :logged_in?, :current_user
  def logged_in?
  	session[:user_id] != nil
  end

  def current_user(id)
  	User.find_by(id: id)
  end
end
