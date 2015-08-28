# config valid only for current version of Capistrano
lock '3.3.3'

set :application, 'alumnet-ui'
set :repo_url, 'https://ranpaco:Pal24Com210@github.com/cooltribes/alumnet-ui.git '#'git@github.com:cooltribes/alumnet-ui.git'
set :scm, :git
set :linked_files, %w{config/application.yml}
set :nginx_sudo_tasks, ['nginx:restart', 'nginx:configtest']
set :pty, true

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
# set :default_env, { secret_key_ui_base: "db5438609fdb4d11ab6de955771f6d58d66fa51410b026977228b7d3403e8780acfe75b0d5bd2cf1355bb7038746ffaed8c618efa89a04f4bcaabbe942871cfc" }
# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

#  desc "Reload Nginx"
#  task :reload_nginx do
#    sudo "/etc/init.d/nginx reload"
#  end
  after :finished, :create_secrets do
    on roles(:all) do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, "app:create_secret_file"
        end
      end
    end
  end
#  after "deploy", "reload_nginx"
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
