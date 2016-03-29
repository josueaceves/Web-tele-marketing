class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  helper_method :current_user, :decode_call_response, :extend_users_number, :answered_by, :seconds_to_time


   def current_user
    @current_user ||=  User.find_by_id(session[:user_id])
  end

  def decode_call_response(response_number)
    response_hash = {"1" => "Le intereza, Favor de regresar la llamada", "2" => "Le Redirigio la llamada", "3" => "No le Intereza", "" => "colgo llamada"}
    response_hash[response_number]
  end

  def extend_users_number(number)
    number.split("").map{|n| n + ".......   "}.join("")
  end

  def answered_by(response, status)
    hash = {"human" => "Una Persona", "machine" => "La contestadora", "" => "Nadie"}
    if status == "no-answer"
       return "No contesto"
    else
      return hash[response]
    end
  end

  def seconds_to_time(seconds)
    [seconds.to_i / 3600, seconds.to_i / 60 % 60, seconds.to_i % 60].map { |t| t.to_s.rjust(2,'0') }.join(':')
  end

end
