class Entry < ActiveRecord::Base
  DESTROY_TEXT = 'Are you sure you want to destroy this entry?'

  belongs_to :user
  before_save :fixup_tags
  after_save :assign_user_tags
  after_destroy :reset_user_tags

  def self.build_search_conditions(options = {})
    fields = []
    top_and = []
    joins = []

    top_and << 'entries.user_id = ?'
    fields << options[:user_id]

    top_and << 'LENGTH(content) > 0'

    if options[:tag]
      top_and << 'tags LIKE ?'
      fields << '% ' + options[:tag].downcase + ' %'
      joins << :tags
    end

    if options[:keywords]
      options[:keywords].split(/\s+/).each do |keyword|
        top_and << 'LOWER(content) LIKE ?'
        fields << '%' + keyword.downcase + '%'
      end
    end

    [top_and.join(' AND '), fields].flatten
  end

  def linkup
    DataDetector.assign_all(self.content.to_s)
  end

  def self.split_tags(tags)
    tags.to_s.downcase.gsub(',', ' ').split.uniq.sort
  end

  def self.pretty_tags(tags)
    split_tags(tags).join(' ')
  end

  def tags_array
    Entry.split_tags(self.tags)
  end

  def pretty_tags
    Entry.pretty_tags(self.tags)
  end

  def plaintext
    "Updated: #{updated_at}\r\n" +
    "Created: #{created_at}\r\n" +
    "Tags: #{pretty_tags}\r\n" +
    content.to_s +
    "\r\n--\r\n"
  end

#  comma do
#    updated_at
#    created_at
#    pretty_tags
#    content.to_s
#  end

private

  def fixup_tags
    self.tags = self.tags.flatten.join(' ') if self.tags.kind_of? Array
    self.tags = self.tags.blank? ? '' : " #{pretty_tags} "
  end

  def assign_user_tags
    user_tags = Entry.split_tags(user.all_tags)
    entry_tags = Entry.split_tags(self.tags)
    all_tags = (user_tags + entry_tags).uniq.sort.join(' ').downcase

    unless user.all_tags == all_tags
      user.all_tags = all_tags
      user.save
    end
  end

  def reset_user_tags
    user.reset_tags
    user.save
  end
end
