class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  helper_method :current_user


   def current_user
    # User.find_by(id: session[:user_id])
    @current_user ||=  User.find_by_id(session[:user_id])
  end
end
