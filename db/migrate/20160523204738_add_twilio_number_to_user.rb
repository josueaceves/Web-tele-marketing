class AddTwilioNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :verified_number, :string
  end
end
