class Entry < ActiveRecord::Base
  belongs_to :user

  before_save :adjust_tags

  FILTERS = {
    'url' => /((http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)$/ix,
    'ups' => /\b(1Z ?[0-9A-Z]{3} ?[0-9A-Z]{3} ?[0-9A-Z]{2} ?[0-9A-Z]{4} ?[0-9A-Z]{3} ?[0-9A-Z]|[\dT]\d\d\d ?\d\d\d\d ?\d\d\d)\b/i,
    'fedex' => /\b(\d\d\d\d ?\d\d\d\d ?\d\d\d\d)\b/i
  }

  def self.find_by_tag(user_id, tag)
    find :all, :conditions => [ 'user_id = ? AND tags LIKE ?', user_id, "% " + tag + " %" ]
  end

  def tags_list
    self.tags.to_s.split(/\s+/).find_all {|tag| !tag.blank?}
  end

  def filter(type)
    regex = FILTERS[type.to_s] || /()/
    result = content.to_s.scan(regex)
    result.map! {|r| r.first.to_s.chomp}
    result.find_all {|r| !r.blank?}
  end

private

  def adjust_tags
    self.tags = tags_list unless tags.kind_of? Array
    self.tags = tags.join(' ').gsub(/\s+/, ' ').strip
    self.tags = ' ' + tags + ' ' # We always pad spaces to make searching by tag easier.
  end
end
