class AddContentTypeToEmail < ActiveRecord::Migration
  def self.up
    add_column :emails, :content_type, :string, :default => 'text/plain'
  end

  def self.down
    remove_column :content_type
  end
end
