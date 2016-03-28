class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  helper_method :current_user, :decode_call_response


   def current_user
    # User.find_by(id: session[:user_id])
    @current_user ||=  User.find_by_id(session[:user_id])
  end

  def decode_call_response(response_number)
    response_hash = {"1" => "Le intereza, Favor de regresar la llamada", "2" => "Le Redirigio la llamada", "3" => "No le Intereza"}
    response_hash[response_number]
  end

end
