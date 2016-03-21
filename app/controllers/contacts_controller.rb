class ContactsController < ApplicationController
  def new
  end

  def create
    @contact_list = current_user.contact_lists.create()
    @contacts = merge_params(contacts_number_params, contacts_name_params)
    filter_empty_contacts(@contacts)
    puts "test to see if this appears on heroku logs"
    p @contact_list
    p @contacts
    @contacts.each do |contact|
      # @contact_list.contacts.create(contact)
      Contact.create({contact_list_id: @contact_list.id }.merge(contact))
    end
    session[:last_contact_list_id] = @contact_list.id
    redirect_to twilio_calls_path(current_user.id, @contact_list.id)
  end

  def delete
  end

  def update
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
end
