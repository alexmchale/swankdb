class Entry < ActiveRecord::Base
  belongs_to :user

  before_save :adjust_tags

  def tags_list
    self.tags.to_s.split(/\s+/).find_all {|tag| !tag.blank?}
  end

private

  def adjust_tags
    self.tags = tags_list unless tags.kind_of? Array
    self.tags = tags.join(' ').gsub(/\s+/, ' ').strip
  end
end
