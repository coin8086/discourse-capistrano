# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'discourse'

set :repo_url, 'username@hostname:~/git/discourse.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "~/#{fetch :application}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp', 'public/uploads', 'public/tombstone', 'public/backups')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

###########################################################
# Set options from 'capistrano/bundler'
set :bundle_flags, "--deployment" # The default is "--deployment --quiet"
set :bundle_without, (fetch(:bundle_without) << ' deployment')

###########################################################
# Set options from 'capistrano/rails'
#
# Skip migration if files in db/migrate were not modified
# set :conditionally_migrate, true

# Defaults to nil (no asset cleanup is performed)
# # If you use Rails 4+ and you'd like to clean up old assets after each deploy,
# # set this to the number of versions to keep
set :keep_assets, 2

namespace :deploy do

  # If you put the production config outside the dir of the code, say "~/discourse.conf", 
  # you can link it at deployment time with this task. 
  # If you save the production config file into repo along with your code, then 
  # you need to comment out this task.
  after :updating, :link_config do
    on roles(:web), in: :parallel do
      within release_path.join('config') do
        execute :ln, '-s', '~/discourse.conf'
      end
    end
  end

  after :finished, :restart_server do
    on roles(:web), in: :parallel do
      within release_path.join('tmp') do
        execute :touch, 'restart.txt'
      end
    end
  end

end
