class Entry < ActiveRecord::Base
  belongs_to :user
  before_save :fixup_tags
  after_save :assign_user_tags
  after_destroy :reset_user_tags

  FILTERS = {
    'url' => /((http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?)$/ix,
    'ups' => /\b(1Z ?[0-9A-Z]{3} ?[0-9A-Z]{3} ?[0-9A-Z]{2} ?[0-9A-Z]{4} ?[0-9A-Z]{3} ?[0-9A-Z]|[\dT]\d\d\d ?\d\d\d\d ?\d\d\d)\b/i,
    'fedex' => /\b(\d\d\d\d ?\d\d\d\d ?\d\d\d\d)\b/,
    'phone' => /((\+?\d{0,2}[ -])?\d{0,3}[ -]\d{3}[ -]\d{4})/
  }

  URLIFIERS = {
    'url' => "%s",
    'ups' => "http://wwwapps.ups.com/WebTracking/processInputRequest?sort_by=status&tracknums_displayed=1&TypeOfInquiryNumber=T&loc=en_US&InquiryNumber1=%s&track.x=0&track.y=0",
    'fedex' => "http://www.fedex.com/Tracking?language=english&cntry_code=us&tracknumbers=%s"
  }

  def self.build_search_conditions(options = {})
    fields = []
    top_and = []
    joins = []

    top_and << 'entries.user_id = ?'
    fields << options[:user_id]

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

  def each_filter_item(type = nil)
    if type
      filter(type).each do |item|
        yield(item, urlify(type, item))
      end
    else
      FILTERS.each do |type, regex|
        filter(type).each do |item|
          yield(type, item, urlify(type, item))
        end
      end
    end
  end

  def filter(type)
    regex = FILTERS[type.to_s] || /()/
    result = content.to_s.scan(regex)
    result.map! {|r| r.first.to_s.chomp}
    result.find_all {|r| !r.blank?}
  end

  def urlify(type, data)
    pattern = URLIFIERS[type.to_s]
    (pattern % data.to_s) if pattern
  end

  def self.split_tags(tags)
    tags.to_s.downcase.split.uniq.sort
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

private

  def fixup_tags
    self.tags = self.tags.to_s.downcase.split.uniq.join(' ')
    self.tags = " " + self.tags + " " unless self.tags.blank?
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
