# config valid only for current version of Capistrano
lock "3.7.2"

set :application, "ethicaltree"
set :repo_url, "git@github.com:applepicke/ethicaltree-api.git"
set :deploy_to, '/home/applepicke/apps/ethicaltree-api'
set :chruby_ruby, 'ruby-2.5.0'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, ".env"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Defaults to nil (no asset cleanup is performed)
# If you use Rails 4+ and you'd like to clean up old assets after each deploy,
# set this to the number of versions to keep
set :keep_assets, 2

set :migration_role, :app

desc "reload application code"
task :reload_unicorn do
  invoke 'unicorn:reload'
end


desc 'Stop the delayed_job process'
task :stop_delayed_job do
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :bundle, :exec, :'bin/delayed_job', :stop
      end
    end
  end
end

desc 'Start the delayed_job process'
task :start_delayed_job do
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :bundle, :exec, :'bin/delayed_job', :start
      end
    end
  end
end

desc 'Restart the delayed_job process'
task :restart_delayed_job do
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :bundle, :exec, :'bin/delayed_job', :restart
      end
    end
  end
end

# after 'deploy:updating', :copy_env
after :deploy, :reload_unicorn
after :deploy, :restart_delayed_job

