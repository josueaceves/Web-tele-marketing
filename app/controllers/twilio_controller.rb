class TwilioController < ApplicationController

  	@@account_sid = ENV['TWILIO_ACCOUNT_SID']
  	@@auth_token = ENV['TWILIO_AUTH_TOKEN']

	def call
  	@phone = params[:phone]
  	@name = params[:name]
	  # set up a client to talk to the Twilio REST API
	  @client = Twilio::REST::Client.new(@@account_sid, @@auth_token)

	  @call = @client.account.calls.create(
	    :from => '+18056234397',   # From your Twilio number
	    :to => '+1' + @phone ,     # To any number
	    # Fetch instructions from this URL when the call connects
	    :url => 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient'
	  )


    # response = Twilio::TwiML::Response.new do |r|
    #   r.Gather numDigits: '1', action: '/call' do |g|
    #     g.Play "http://howtodocs.s3.amazonaws.com/et-phone.mp3", loop: 3
    #   end
    # end

    # render text: response.text

    
	  render :nothing => true, :status => 200, :content_type => 'text/html'
	end


	def verify_number
		# @user = current_user
    @phone = params[:phone_to_verify]
		@client = Twilio::REST::Client.new(@@account_sid, @@auth_token)
		caller_id = @client.account.outgoing_caller_ids.create(:friendly_name => "My Home Phone Number",
    :phone_number => "+1" + @phone)
		puts caller_id.validation_code
    render :nothing => true, :status => 200, :content_type => 'text/html'

	end

end