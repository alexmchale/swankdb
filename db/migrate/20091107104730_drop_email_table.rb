class DropEmailTable < ActiveRecord::Migration
  def self.up
    drop_table "emails"
  end

  def self.down
    create_table "emails", :force => true do |t|
      t.integer  "user_id"
      t.string   "subject"
      t.text     "body"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "destination"
      t.string   "content_type", :default => "text/plain"
    end
  end
end
