class ErrorMailer < ActionMailer::Base

  def snapshot(exception, trace, session, params, env)

    @exception = exception
    @trace     = trace
    @session   = session
    @user      = User.find_by(id: session.andand[:user_id])
    @params    = params
    @env       = env

    mail :to      => 'alexmchale@gmail.com',
         :from    => 'swank@swankdb.com',
         :subject => "[SwankDB Error] #{env['REQUEST_URI']}"

  end

end
