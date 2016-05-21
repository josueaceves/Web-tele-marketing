class ContactListsController < ApplicationController
  before_filter :logged_in?

  def index

    # TODO: reset code below when Montero subscription ends
    if current_user.email == "nuvilife.jose13@gmail.com" && current_user.number == "7145913108"
      @account_sid = ENV['TWILIO_MONTERO_ACCOUNT_SID']
    	@auth_token = ENV['TWILIO_MONTERO_AUTH_TOKEN']

      p "*******************************"
      p "contact list controller"
      p "this  app is running with the right env variables"
      p @account_sid
      p @auth_token
      p "*******************************"

    elsif current_user.email == "josueaceves.ja@gmail.com"
      p "using josues account"
    	@account_sid = ENV['TWILIO_ACCOUNT_SID']
    	@auth_token = ENV['TWILIO_AUTH_TOKEN']
    end

    @client = Twilio::REST::Client.new(@account_sid, @auth_token)
    @lists = current_user.contact_lists
  end

  def create
    @user = User.find_by(id: current_user.id)
    @contact_list = @user.contact_lists.create()
    @contacts = merge_params(contacts_number_params, contacts_name_params)
    filter_empty_contacts(@contacts)
    @contacts.each do |contact|
      @contact_list.contacts.create(contact)
    end
    session[:last_contact_list_id] = @contact_list.id
    redirect_to twilio_calls_path(current_user.id, @contact_list.id)
  end

  private
  def contacts_name_params
    params.require(:name).permit(:one, :two, :three, :four, :five, :six, :seven, :eight, :nine, :ten)
  end

  def contacts_number_params
    params.require(:phone).permit(:one, :two, :three, :four, :five, :six, :seven, :eight, :nine, :ten)
  end

  def merge_params(numbers, names)
    array_of_contacts = []
    numbers.each do |key, value|
      array_of_contacts << {phone: value, name: names[key]}
    end
    return array_of_contacts
  end

  def filter_empty_contacts(contacts)
    contacts.each do |contact|
      if contact[:phone] == ""
        contacts.delete(contact)
      end
    end
  end



	def logged_in?
		if session[:user_id] == nil
			redirect_to root_path
		end
	end
end
