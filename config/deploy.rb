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

# NOTE:
# 1) You may want to comment out the following 2 line of code if you want to
# follow Bundler's default behavior for deployment, that is to install all
# Gems into vendor/bundle, rather a dir under ~/.rvm.
# 2) If you want to avoid any network download for Gems, do it as:
# set :bundle_flags, "--local"
# Since we have already run "bundle package" and saved the Gems in vendor/cache
# in Git repo, bundler is smart to find it and will install Gems from it.
set :bundle_flags, nil # default to "--deployment --quiet"
set :bundle_path, nil

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

  # If you choose to put the production config out of the code repo, you could
  # link it at each deployment like this:
  after :updating, :config_app do
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

  # after :restart, :clear_cache do
  #   on roles(:web), in: :groups, limit: 3, wait: 10 do
  #     # Here we can do anything such as:
  #     # within release_path do
  #     #   execute :rake, 'cache:clear'
  #     # end
  #   end
  # end

end
