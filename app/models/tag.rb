class Tag < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry

  before_save :downcase_name

  def self.suggest(keyword, limit = 20)
    keyword = keyword.gsub(/\\/, '\&\&').gsub(/'/, "''")
    limit = limit.to_i

    ActiveRecord::Base.connection.execute("
      SELECT COUNT(*) AS count, name
      FROM tags
      WHERE name LIKE '%s%%'
      GROUP BY name ORDER BY count DESC LIMIT %d
    " % [ keyword, limit ])
  end

private

  def downcase_name
    self.name = name.strip.downcase if name
    self.readonly! if self.name.blank?
  end
end
