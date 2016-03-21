class CreateContactLists < ActiveRecord::Migration
  def change
    create_table :contact_lists do |t|
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
