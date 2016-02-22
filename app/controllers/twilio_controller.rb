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
      # :url => 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient'
      :url => root_url+"connect"

    )
	  render :nothing => true, :status => 200, :content_type => 'text/html'
	end

  def connect
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Si esta interesado, porfavor marcar el numero 1. De otra manera oprima el 2.',language: 'es-MX'
    end
    render text: response.text
  end

  def ivr_welcome
    response = Twilio::TwiML::Response.new do |r|
      r.Gather numDigits: '1', action: menu_path do |g|
        g.Play "http://howtodocs.s3.amazonaws.com/et-phone.mp3", loop: 3
      end
    end
     render text: response.text
  end


  def menu_selection
    user_selection = params[:Digits]

    case user_selection
    when "1"
      @output = "Thank you for your time Have a beautiful day"
      twiml_say(@output, true)
    when "2"
      @output = "One of our representatives will call you soon"
      twiml_say(@output, true)
      puts "client success"
    else
      @output = "Returning to the main menu."
      twiml_say(@output)
    end
  end

  def twiml_say(phrase, exit = false)
    # Respond with some TwiML and say something.
    # Should we hangup or go back to the main menu?
    response = Twilio::TwiML::Response.new do |r|
      r.Say phrase, voice: 'alice', language: 'en-GB'
      if exit
        r.Say "Thank you for calling the ET Phone Home Service - the
        adventurous alien's first choice in intergalactic travel."
        r.Hangup
      else
        r.Redirect welcome_path
      end
    end

    render text: response.text
  end

  def twiml_dial(phone_number)
    response = Twilio::TwiML::Response.new do |r|
      r.Dial phone_number
    end

    render text: response.text
  end


	def verify_number
    @phone = params[:phone_to_verify]
		@client = Twilio::REST::Client.new(@@account_sid, @@auth_token)
		caller_id = @client.account.outgoing_caller_ids.create(:friendly_name => "My Home Phone Number",
    :phone_number => "+1" + @phone)
    puts caller_id.validation_code
		puts caller_id.verification_status
    render :nothing => true, :status => 200, :content_type => 'text/html'
	end

end
