# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


@user = User.create(first_name: "Josue", last_name: "Aceves", number: "8052609738", email: "josueaceves.ja@gmail.com", password: "password")

10.times do
  @contact_list = @user.contact_lists.create()
  10.times do
    @contact_list.contacts.create(name: Faker::Name.name, phone: Faker::PhoneNumber.cell_phone)
  end
end
