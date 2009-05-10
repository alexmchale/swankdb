class Entry < ActiveRecord::Base
  belongs_to :user

  before_save :adjust_tags

  def self.find_by_tag(user_id, tag)
    find :all, :conditions => [ 'user_id = ? AND tags LIKE ?', user_id, "% " + tag + " %" ]
  end

  def tags_list
    self.tags.to_s.split(/\s+/).find_all {|tag| !tag.blank?}
  end

private

  def adjust_tags
    self.tags = tags_list unless tags.kind_of? Array
    self.tags = tags.join(' ').gsub(/\s+/, ' ').strip
    self.tags = ' ' + tags + ' ' # We always pad spaces to make searching by tag easier.
  end
end
