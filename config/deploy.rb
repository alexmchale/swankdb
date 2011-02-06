require "bundler/capistrano"
require "#{File.dirname __FILE__}/deploy/capistrano_database_yml"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :application, "swankdb"
set :repository, "git@github.com:alexmchale/swankdb.git"
set :scm, "git"
set :user, "alexmchale"
set :branch, "master"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :deploy_to, "/srv/http/swankdb"
set :use_sudo, true
set :migrate_env, "production"

role :web, "swankdb.com"
role :app, "swankdb.com"
role :db,  "swankdb.com"

namespace :deploy do
  task :restart, :roles => :app do
    run "sudo chown -R http.http /srv/http"
    run "sudo chmod -R g+w /srv/http"
    run "sudo /etc/rc.d/thin restart"
  end
  task :stop, :roles => :app do
    run "sudo /etc/rc.d/thin stop"
  end
  task :start, :roles => :app do
    run "sudo chown -R http.http /srv/http"
    run "sudo chmod -R g+w /srv/http"
    run "sudo /etc/rc.d/thin start"
  end
end
