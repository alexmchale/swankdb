while Email.count > 0
  email = Email.first
  retries = 3

  retries -= 1 until (retries == 0) || email.dispatch

  email.destroy
end
