class User < ActiveRecord::Base
  has_many :active_codes
  before_save :rehash_password

  def self.authenticate(username, password)
    User.find :first,
              :conditions => { :username => username.to_s.downcase,
                               :password => hash_password(username, password) }
  end

  def tags
    Entry.split_tags(self.all_tags)
  end

  def suggest_tags(base)
    tags.find_all {|tag| tag =~ /#{base}/}
  end

  def count_tags(tag)
    Entry.count(:conditions => [ 'tags LIKE ?', '% ' + tag + ' %' ])
  end

  def reset_tags
    self.all_tags = Entry.find(:all, :conditions => { :user_id => id }).map do |e|
      e.tags.to_s.split
    end.flatten.uniq.sort.join(' ')
  end

  def frob
    frobs.first || new_active_code('frob').code
  end

  def frobs
    active_codes.find_all {|c| c.section == 'frob'}.map {|c| c.code}
  end

  def active_code(section)
    code = self.active_codes.find_all {|c| c.section == section.downcase}.andand.first

    if code.andand.expires_at && code.expires_at < Time.now
      code.destroy
      self.reload
      code = nil
    end

    code
  end

  def new_active_code(section, expires_at = nil)
    new_code = ActiveCode.new
    new_code.user = self
    new_code.section = section.downcase
    new_code.code = Digest::SHA1.hexdigest(rand(2**256).to_s)
    new_code.expires_at = expires_at
    new_code.save

    self.reload

    active_code(section)
  end

  def add_default_entry
    entry = Entry.new
    entry.user = self
    entry.content = File.read('config/welcome.txt')
    entry.tags = 'hello swankdb'
    entry.save

    reload
  end

  def temporary
    username.blank?
  end

private

  def rehash_password
    if password_changed?
      self.password = User.hash_password(username, password)
    end
  end

  def self.hash_password(username, password)
    Digest::MD5.hexdigest("!!! %s WITH MY SALT %s !!!" % [ username.to_s.strip, password.to_s.strip ])
  end
end
