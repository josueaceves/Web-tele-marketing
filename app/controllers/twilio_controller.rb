class TwilioController < ApplicationController
  respond_to :js, :html

  # TODO: reset code below when Montero subscription ends
  def define_env_credentials
    # if current_user.email == "nuvilife.jose13@gmail.com" || current_user.number == "9512244201"
    #   @@account_sid = ENV['TWILIO_MONTERO_ACCOUNT_SID']
    # 	@@auth_token = ENV['TWILIO_MONTERO_AUTH_TOKEN']
    # elsif current_user.email == "josueaceves.ja@gmail.com"
    	@@account_sid = ENV['TWILIO_ACCOUNT_SID']
    	@@auth_token = ENV['TWILIO_AUTH_TOKEN']
    # end
  end

	def call
    define_env_credentials
    @list = current_user.contact_lists.find_by(id: session[:last_contact_list_id])
  	@contacts = @list.contacts
	  # set up a client to talk to the Twilio REST API
	  @client = Twilio::REST::Client.new(@@account_sid, @@auth_token)
    @contacts.each do |contact|
  	  @call = @client.account.calls.create(
  	    :from => '+1' + current_user.number,   # From your Twilio number
  	    :to => '+1' + contact.phone ,     # To any number
  	    # Fetch instructions from this URL when the call connects
        :if_machine => "hangup",
        :status_callback_method => "POST",
        :url => root_url + "connect?user_id=#{session[:user_id]}&last_contact_list_id=#{session[:last_contact_list_id]}&current_user_phone=#{current_user.number}"
      )

      sid = @call.sid
      contact_in_list = @list.contacts.find_by(phone: contact.phone)
      contact_in_list.sid = sid
      contact_in_list.save
    end
    redirect_to root_path
	end

  def connect
    response = Twilio::TwiML::Response.new do |r|
      r.Play 'https://a.clyp.it/egzwruej.mp3'
      r.Gather numDigits: '1', action: menu_path(:user_id => params[:user_id], :last_contact_list_id => params[:last_contact_list_id], :current_user_phone => params[:current_user_phone]) do |g|
        g.Play 'https://a.clyp.it/wysrt2in.mp3'
      end
    end
    # render text: response.text
    render :xml => response.to_xml
  end

  def menu_selection
    @client = Twilio::REST::Client.new(@@account_sid, @@auth_token)
    list = User.find_by(id: params[:user_id]).contact_lists.find_by(id: params[:last_contact_list_id])
    user_selection = params[:Digits]
    number = params[:Called]
    sid = params[:CallSid]
    contact = list.contacts.find_by(phone: number[2..-1])
    case user_selection
    when "1"
      contact.response = "1"
      contact.save
      @output = "Uno de nuestros representatantes se comunicara con usted en seguida."
      twiml_say(@output)
    when "2"
      contact.response = "2"
      contact.save
      twiml_dial("+1" + params[:current_user_phone])
    when "3"
      contact.response = "3"
      contact.save
      @client.calls.get(sid).hangup()
    end
  end


  def twiml_say(phrase)
    # Respond with some TwiML and say something.
    # Should we hangup or go back to the main menu?
    response = Twilio::TwiML::Response.new do |r|
      r.Say phrase, voice: 'alice', language:'es-MX'
      r.Hangup
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
