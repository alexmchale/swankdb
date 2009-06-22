class User < ActiveRecord::Base
  before_save :rehash_password

  def self.authenticate(username, password)
    User.find :first,
              :conditions => { :username => username.downcase,
                               :password => hash_password(username, password) }
  end

  def tags
    Entry.find(:all, :conditions => { :user_id => id }).map {|e| e.tags.split}.flatten.uniq.sort
  end

private

  def rehash_password
    if username_changed? || password_changed?
      self.password = User.hash_password(username, password)
    end
  end

  def self.hash_password(username, password)
    Digest::MD5.hexdigest("!!! %s WITH MY SALT %s !!!" % [ username, password ])
  end
end
