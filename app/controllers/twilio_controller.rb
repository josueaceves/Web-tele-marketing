class TwilioController < ApplicationController
    respond_to :js, :html
  	@@account_sid = ENV['TWILIO_ACCOUNT_SID']
  	@@auth_token = ENV['TWILIO_AUTH_TOKEN']
    @@session = session[:last_contact_list_id
    @@list = current_user.contact_lists.find_by(id: session[:last_contact_list_id])

	def call
    puts "list below in #call"
    p @@list
  	@contacts = @list.contacts
	  # set up a client to talk to the Twilio REST API
	  @client = Twilio::REST::Client.new(@@account_sid, @@auth_token)

    @contacts.each do |contact|
  	  @call = @client.account.calls.create(
  	    :from => '+18056234397',   # From your Twilio number
  	    :to => '+1' + contact.phone ,     # To any number
  	    # Fetch instructions from this URL when the call connects
        :url => root_url + "connect"
      )

      sid = @call.sid
      contact_in_list = @@list.contacts.find_by(phone: contact.phone)
      contact_in_list.sid = sid
      contact_in_list.save
    end
    redirect_to root_path
	end

  def connect
    response = Twilio::TwiML::Response.new do |r|
      r.Play 'https://clyp.it/l1qz52x5.mp3'
      r.Gather numDigits: '1', action: menu_path do |g|
        g.Play 'https://a.clyp.it/2mue3ocn.mp3'
      end
    end
    # render text: response.text
    render :xml => response.to_xml
  end

  def menu_selection
    user_selection = params[:Digits]
    call_sid = params[:CallSid]
    number = params[:Called]
    @client = Twilio::REST::Client.new(@@account_sid, @@auth_token)
    puts "list below"
    p @@list
    case user_selection
    when "1"
      contact = @@list.contacts.find_by(phone: number)
      contact.response = "1"
      contact.save
      @output = "Uno de nuestros representatantes se comunicara con usted en seguida."
      twiml_say(@output, true)
    when "2"
      contact = @@list.contacts.find_by(phone: number)
      contact.response = "2"
      contact.save
      twiml_dial("+18052609071")
    when "3"
      contact = @@list.contacts.find_by(phone: number)
      contact.response = "3"
      contact.save
      @output = "Asta luego..."
      twiml_say(@output, true)
    end
  end


  def twiml_say(phrase, exit = false)
    # Respond with some TwiML and say something.
    # Should we hangup or go back to the main menu?
    response = Twilio::TwiML::Response.new do |r|
      r.Say phrase, voice: 'alice', language:'es-MX'
      r.Hangup
      # if exit
      #   r.Hangup
      # else
      #   r.Redirect menu_path
      # end
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
