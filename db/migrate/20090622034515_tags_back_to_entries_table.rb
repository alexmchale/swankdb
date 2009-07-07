class TagsBackToEntriesTable < ActiveRecord::Migration
  def self.up
    drop_table :tags
    add_column :entries, :tags, :string
  end

  def self.down
  end
end
