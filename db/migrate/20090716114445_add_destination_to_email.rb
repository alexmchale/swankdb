class AddDestinationToEmail < ActiveRecord::Migration
  def self.up
    add_column :emails, :destination, :string
  end

  def self.down
    remove_column :emails, :destination
  end
end
