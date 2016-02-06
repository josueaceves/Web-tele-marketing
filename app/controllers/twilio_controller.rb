class TwilioController < ApplicationController

	def call
  	@account_sid = ENV['TWILIO_ACCOUNT_SID']
  	@auth_token = ENV['TWILIO_AUTH_TOKEN']
  	@phone = params[:phone]
  	@name = params[:name]
	  # set up a client to talk to the Twilio REST API
	  @client = Twilio::REST::Client.new(@account_sid, @auth_token)
	   
	  @call = @client.account.calls.create(
	    :from => '+18052609071',   # From your Twilio number
	    :to => '+1' + @phone ,     # To any number
	    # Fetch instructions from this URL when the call connects
	    :url => 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient'
	  )
	  render :nothing => true, :status => 200, :content_type => 'text/html'
	end
end