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
    self.all_tags = Entry.find(:all, :conditions => { :user_id => id }).map {|e| e.tags.split}.flatten.uniq.sort.join(' ')
  end

  def active_code(section)
    code = self.active_codes.find_all {|c| c.section == section.downcase}.andand.first

    if code && code.created_at < (Time.now - 2.days)
      code.destroy
      self.reload
      code = nil
    end

    code
  end

  def new_active_code(section)
    current = active_code(section)
    current.andand.destroy

    new_code = ActiveCode.new
    new_code.user = self
    new_code.section = section.downcase
    new_code.code = Digest::SHA1.hexdigest(rand(2**256).to_s)
    new_code.save

    self.reload

    active_code(section)
  end

private

  def rehash_password
    if username_changed? || password_changed?
      self.password = User.hash_password(username, password)
    end
  end

  def self.hash_password(username, password)
    Digest::MD5.hexdigest("!!! %s WITH MY SALT %s !!!" % [ username.to_s, password.to_s ])
  end
end
