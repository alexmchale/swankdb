class AddAllTagsFieldToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :all_tags, :text
  end

  def self.down
    drop_column :users, :all_tags
  end
end
