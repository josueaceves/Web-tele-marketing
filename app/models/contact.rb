class Contact < ActiveRecord::Base
	belongs_to :user
  include ActiveModel::Validations
  attr_accessor :name, :phone
  validates_presence_of :name, :phone
  validates :phone, :phony_plausible => true
end
