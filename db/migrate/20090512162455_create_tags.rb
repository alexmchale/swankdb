class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.references :user
      t.references :entry
      t.string :name

      t.timestamps
    end

    Entry.all.each do |entry|
      entry.tags.to_s.split(/\s+/).find_all do |tag| 
        !tag.blank?
      end.each do |tag|
        t = Tag.new
        t.user_id = entry.user_id
        t.entry_id = entry.id
        t.name = tag
        t.save
      end
    end

    remove_column :entries, :tags
  end

  def self.down
    drop_table :tags
    add_column :entries, :tags, :string
  end
end
