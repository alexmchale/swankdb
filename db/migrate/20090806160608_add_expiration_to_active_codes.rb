class AddExpirationToActiveCodes < ActiveRecord::Migration
  def self.up
    add_column :active_codes, :expires_at, :datetime
  end

  def self.down
    remove_column :active_codes, :expires_at
  end
end
