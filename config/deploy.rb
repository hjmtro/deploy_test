# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'deploy_test'
set :repo_url, 'git@github.com:hjmtro/deploy_test.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/deploy_test'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'run/sockets', 'public/system') # add

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :rbenv_custom_path, '$HOME/.rbenv' # add
set :rbenv_path, '$HOME/.rbenv' # add
set :rbenv_ruby, '2.3.1' # add

# Default value for keep_releases is 5
set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      #within release_path do
      #   execute :rake, 'cache:clear'
      #end

      # add # gem install unicorn, rack
      # add これはいらなさそう # chown -R vagrant:vagrant www
    end
  end

  # add
  desc 'Upload database.yml and secrets.yml'
  task :upload do
    on roles(:app) do |host|
      #if test "[ ! -d #{shared_path}/config ]"
      #  execute "mkdir -p #{shared_path}/config"
      #end
      upload!('config/database.yml', "#{shared_path}/config/database.yml")
      upload!('config/secrets.yml', "#{shared_path}/config/secrets.yml")
    end
  end
  after 'deploy:check:make_linked_dirs', 'deploy:upload'
  #before :starting, 'deploy:upload'

  # add
  desc 'Restart application'
  task :restart do
    invoke 'unicorn:restart'
  end
  after 'deploy:publishing', 'deploy:restart'

end
