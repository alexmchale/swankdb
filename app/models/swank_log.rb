class SwankLog < ActiveRecord::Base
  def self.log(code, message)
    sl = SwankLog.new
    sl.code = code
    sl.message = message.kind_of?(String) ? message : message.to_yaml
    sl.save
  end

  def self.codes
    find(:all, :group => :code).map {|l| l.code}.sort
  end

  def parsed
    YAML.load self.message
  end
end
