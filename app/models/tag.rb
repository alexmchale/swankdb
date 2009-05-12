class Tag < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry

  before_save :downcase_name

private

  def downcase_name
    self.name = name.downcase if name
  end
end
