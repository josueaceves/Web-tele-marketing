class AddCallsidToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :sid, :string
    add_column :contacts, :response, :string

  end
end
