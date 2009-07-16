class Email < ActiveRecord::Base
  belongs_to :user

  def dispatch
    begin
      GMail.new('swank@swankdb.com', 'bt60M32FWfJHOX7O1yaY').send(destination, subject, body)
      true
    rescue
      false
    end
  end
end
