class TwilioController < ApplicationController
    respond_to :js, :html
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
      :url => root_url+"connect"
    )

	  render :nothing => true, :status => 200, :content_type => 'text/html'
	end

  def connect
    response = Twilio::TwiML::Response.new do |r|
      r.Play 'http://demo.twilio.com/hellomonkey/monkey.mp3'
      r.Gather numDigits: '1', action: menu_path do |g|
        g.Say 'Si le intereza saver mas  porfavor oprima el numero 1. Si le intereza hablar con un representante acerca de ello, oprima en numero 2. Si desea no ser molestado oprima el numero 3', voice: 'alice', language:'es-MX', loop: 2
      end
    end
    # render text: response.text
    render :xml => response.to_xml
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
    @phone = current_user.number
		@client = Twilio::REST::Client.new(@@account_sid, @@auth_token)
		@caller_id = @client.account.outgoing_caller_ids.create(:friendly_name => "#{current_user.first_name} #{current_user.email}",
    :phone_number => "+1" + @phone)
    @user.call_sid = @caller_id.call_sid
    @user.save

    @caller_id.verification_status

    if request.xhr?
      render :json => {:code => @caller_id.validation_code}
    end
	end

  def check_verification
    @phone = current_user.number
    @client = Twilio::REST::Client.new(@@account_sid, @@auth_token)
    @caller_id = @client.account.outgoing_caller_ids.get(current_user.caller_sid)
    if @caller_id.verification_status == "success"
      user = current_user
      user.verified = true
      user.save
    end

    if request.xhr?
     render :json => {:response => @caller_id.verification_status}
    end
  end

end
