class UserEmails < ActionMailer::Base
  def invitation(user, destination, message, subject = nil)
    @recipients = destination.to_s.strip
    @subject = subject || "#{user.andand.username.to_s.capitalize} invites you to try SwankDB"

    @body = {
      :username => user.andand.username,
      :email => user.andand.email.to_s.strip,
      :message => message.to_s.strip
    }

    @headers['reply-to'] = user.andand.email unless user.andand.email.blank?
  end

  def password_reset_request(user, reset_url)
    @recipients = user.email.to_s.strip
    @subject = 'Password reset requested on SwankDB'

    @body = {
      :reset_url => reset_url
    }
  end

  def entry(user, destination, subject, entry)
    @recipients = destination.to_s.strip
    @subject = subject || "A Swank Note from #{user.andand.username.to_s.capitalize}"

    @body = {
      :content => entry.andand.render
    }

    @content_type = 'text/html'
    @headers['reply-to'] = user.andand.email unless user.andand.email.blank?
  end
end
