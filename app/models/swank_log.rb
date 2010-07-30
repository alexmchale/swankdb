require 'user'

class SwankLog < ActiveRecord::Base
  def self.log(code, message)
    sl = SwankLog.new
    sl.code = code
    sl.message = message.to_json
    sl.save && sl.reload
  end

  def self.codes
    all(:group => :code).map {|l| l.code}.sort
  end
end
