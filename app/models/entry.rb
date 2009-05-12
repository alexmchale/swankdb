class Entry < ActiveRecord::Base
  belongs_to :user
  has_many :tags
  before_destroy :remove_tags

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

  def self.search(options = {})
    fields = []
    top_and = []
    joins = []

    top_and << 'entries.user_id = ?'
    fields << options[:user_id]

    if options[:tag]
      top_and << 'tags.name LIKE ?'
      fields << options[:tag].downcase
      joins << :tags
    end

    if options[:keywords]
      options[:keywords].split(/\s+/).each do |keyword|
        top_and << 'LOWER(content) LIKE ?'
        fields << '%' + keyword.downcase + '%'
      end
    end

    entries = Entry.find(:all,
                         :conditions => [top_and.join(' AND '), fields].flatten,
                         :joins => joins,
                         :order => options[:order])

    if options[:with]
      entries = entries.find_all {|e| e.filter(options[:with]).andand.length > 0}
    end

    entries
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

  def set_tags_from_string(s)
    new_tags = s.downcase.
                 gsub(/[^ a-z0-9\-]/, '').
                 gsub(/\s+/, ' ').
                 split(/\s+/).
                 map {|t| t.strip}.
                 find_all {|t| !t.blank?}

    # Remove tags that were used, but are not anymore.
    self.tags.each do |t|
      next if new_tags.include? t.name.downcase
      t.destroy
    end

    save && reload

    # Do not re-create tags that already exist.
    new_tags.delete_if {|t| self.tags.map {|t1| t1.name}.include?(t)}

    new_tags.each do |name|
      t = Tag.new
      t.user_id = user_id
      t.entry_id = id
      t.name = name
      self.tags << t
    end

    save && reload
  end

private

  def remove_tags
    self.tags = []
    save && reload
  end
end
