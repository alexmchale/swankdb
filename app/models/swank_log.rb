class SwankLog < ActiveRecord::Base
  def self.log(code, message)
    sl = SwankLog.new
    sl.code = code
    sl.message = message
    sl.save
  end

  def self.codes
    find(:all, :group => :code).map {|l| l.code}.sort
  end
end
