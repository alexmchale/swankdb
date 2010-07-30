class UserEmails < ActionMailer::Base

  default :from => "swank@swankdb.com"

  def invitation(user, destination, message, subject = nil)

    @username = user.andand.username
    @email    = user.andand.email.to_s.strip
    @subject  = subject || "#{user.andand.username.to_s.capitalize} invites you to try SwankDB"
    @message  = message.to_s.strip
    @reply_to = user.andand.email unless user.andand.email.blank?

    mail :to       => destination,
         :subject  => @subject,
         :reply_to => @reply_to

  end

  def password_reset_request(user, reset_url)

    @reset_url = reset_url

    mail :to      => user.andand.email.to_s.strip,
         :subject => "Password reset requested on SwankDB"

  end

  def entry(user, destination, subject, entry)

    @content    = entry.andand.render
    @recipients = destination.to_s.strip
    @subject    = subject || "A Swank Note from #{user.andand.username.to_s.capitalize}"
    @reply_to   = user.andand.email unless user.andand.email.blank?

    mail :to           => @recipients,
         :subject      => @subject,
         :reply_to     => @reply_to,
         :content_type => "text/html"

  end

end
