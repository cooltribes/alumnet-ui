# config valid only for current version of Capistrano
lock '3.3.3'

set :application, 'alumnet-ui'
set :repo_url, 'https://ArmandoMendoza:14941830famg@github.com/cooltribes/alumnet-ui.git '#'git@github.com:cooltribes/alumnet-ui.git'
set :deploy_to, '/home/ec2-user/alumnet/alumnet-ui'
set :branch, 'deploy'
set :scm, :git

set :linked_files, %w{config/application.yml config/.env}

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc "Reload Nginx"
  task :reload_nginx do
    sudo "/etc/init.d/nginx reload"
  end

  after "deploy", "reload_nginx"
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
