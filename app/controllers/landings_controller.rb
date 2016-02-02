class LandingsController < ApplicationController
	before_filter :logged_in?, only: [:index]
	def index
		render 'index'
	end

	private
	def logged_in?
		if session[:user_id] != nil
			redirect_to user_path(session[:user_id])
		end
	end
end