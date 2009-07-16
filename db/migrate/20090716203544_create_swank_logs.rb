class CreateSwankLogs < ActiveRecord::Migration
  def self.up
    create_table :swank_logs do |t|
      t.string :code
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :swank_logs
  end
end
