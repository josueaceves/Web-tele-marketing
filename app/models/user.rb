class User < ActiveRecord::Base
	has_secure_password
	has_many :contact_lists
	has_many :contacts, through: :contact_lists

	validates :email, uniqueness: true
end
