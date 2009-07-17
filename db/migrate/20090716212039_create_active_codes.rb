class CreateActiveCodes < ActiveRecord::Migration
  def self.up
    create_table :active_codes do |t|
      t.references :user
      t.string :section
      t.string :code

      t.timestamps
    end
  end

  def self.down
    drop_table :active_codes
  end
end
