class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.references :user
      t.text :content
      t.string :tags

      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end
