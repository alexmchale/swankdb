class Email < ActiveRecord::Base
  belongs_to :user

  def dispatch
    begin
      content_type = self.content_type.blank? ? 'text/plain' : self.content_type
      GMail.new('swank@swankdb.com', 'bt60M32FWfJHOX7O1yaY').send(destination, subject, body, content_type)
      true
    rescue
      false
    end
  end
end
