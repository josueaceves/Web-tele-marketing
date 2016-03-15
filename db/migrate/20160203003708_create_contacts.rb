class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :phone
      t.integer :contact_list_id

      t.timestamps null: false
    end
  end
end
