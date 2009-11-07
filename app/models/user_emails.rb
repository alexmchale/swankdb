class UserEmails < ActionMailer::Base
  def invitation(user, destination, message, subject = nil)
    @recipients = destination.to_s.strip
    @subject = subject || "#{user.andand.username.to_s.capitalize} invites you to try SwankDB"

    @body = {
      :username => user.andand.username,
      :email => user.andand.email,
      :message => message.to_s.strip
    }

    @headers['reply-to'] = user.andand.email unless user.andand.email.blank?
  end
end
