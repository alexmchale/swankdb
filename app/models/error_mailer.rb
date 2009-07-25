class ErrorMailer < ActionMailer::Base
  def snapshot(exception, trace, session, params, env)
    content_type "text/html"
    recipients ['alexmchale@gmail.com']
    from 'swank@swankdb.com'
    subject "[Error] exception in #{env['REQUEST_URI']}"

    @body["exception"] = exception
    @body["trace"]  = trace
    @body["session"]  = session
    @body["params"]  = params
    @body["env"]   = env
  end
end
