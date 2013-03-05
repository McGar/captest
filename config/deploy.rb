# config/deploy.rb 
require "bundler/capistrano"

set :scm,             :git
set :repository,      "https://github.com/McGar/captest.git"
set :branch,          "origin/master"
set :migrate_target,  :current
set :ssh_options,     { :forward_agent => true }
set :rails_env,       "production"
set :deploy_to,       "/var/www/rubydev.aicure.com/captest"
set :normalize_asset_timestamps, false

set :user,            "cjiang"
set :scm_username,    "McGar"
set :password,        "20120313"
set :scm_passphrase,  "Mg1123581321"
# set :group,           "staff"
set :use_sudo,        true
# set :gateway, "rubydev.aicure.com"
# set :gateway, "204.13.110.73"
role :web,    "rubydev.aicure.com"
role :app,    "rubydev.aicure.com"
role :db,     "rubydev.aicure.com", :primary => true

set(:latest_release)  { fetch(:current_path) }
set(:release_path)    { fetch(:current_path) }
set(:current_release) { fetch(:current_path) }

set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

# Specify PATH here
set :default_environment, {
    'PATH' => "/usr/local/rvm/gems/ruby-1.9.3-p374/bin:/usr/local/rvm/gems/ruby-1.9.3-p374@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p374/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:$PATH"
}


default_environment["RAILS_ENV"] = 'production'
# Enable :pty or :tty
default_run_options[:pty] = true
#  Use ruby-1.9.3-p374@cjiang gemset
#  default_environment["PATH"]         = "--"
#  default_environment["GEM_HOME"]     = "--"
#  default_environment["GEM_PATH"]     = "--"
#  default_environment["RUBY_VERSION"] = "ruby-1.9.3-p374"
#
#  default_run_options[:shell] = 'bash'

namespace :deploy do
  desc "Deploy your application"
  task :default do
    update
    restart
  end

  desc "Setup your git-based deployment app"
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, shared_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
    run "sudo git clone #{repository} #{current_path}"

  end

  task :cold do
    update
    migrate
  end

  task :update do
    transaction do
      update_code
    end
  end

  desc "Update the deployed code."
  task :update_code, :except => { :no_release => true } do
    # chmod make sure bundle install succeed
    # run "cd #{current_path}; cd ../; #{try_sudo} chmod -R 777 shared"
    run "#{try_sudo} chmod -R 777 #{shared_path}"
    run "#{try_sudo} chmod -R 777 #{current_path}"
    run "cd #{current_path};#{try_sudo} git fetch origin; #{try_sudo} git reset --hard #{branch}"

    finalize_update
  end

  desc "Update the database (overwritten to avoid symlink)"
  task :migrations_only do
    transaction do
      update_code
    end
    migrate
  end


  desc "Update the database (overwritten to avoid symlink)"
  task :migrations do
    transaction do
      update_code
    end
    migrate
    restart
  end

  task :finalize_update, :except => { :no_release => true } do
    # chmod it back
    run "#{try_sudo} chmod -R 777 #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't
    # save empty folders
    run <<-CMD
      #{try_sudo} rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      mkdir -p #{latest_release}/public/system &&
      mkdir -p #{latest_release}/tmp/pids &&
      mkdir -p #{shared_path}/pids &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/public/system #{latest_release}/public/system &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
      ln -sf #{latest_release}/config/database.yml #{shared_path}/database.yml
    CMD

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end

  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "kill -s USR2 `cat /tmp/unicorn.captest.pid`"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    # use rvmsudo instead of sudo, and make sure rvmsudo can work
    run "cd #{current_path} ;#{try_sudo} touch newfile; rvmsudo bundle exec unicorn_rails -c config/unicorn.rb -D; #{try_sudo} rm newfile"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "kill -s QUIT `cat /tmp/unicorn.captest.pid`"
  end

  namespace :rollback do
    desc "Moves the repo back to the previous version of HEAD"
    task :repo, :except => { :no_release => true } do
      set :branch, "HEAD@{1}"
      deploy.default
    end

    desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
    task :cleanup, :except => { :no_release => true } do
      run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
    end

    desc "Rolls back to the previously deployed version."
    task :default do
      rollback.repo
      rollback.cleanup
    end
  end
end

def run_rake(cmd)
  run "cd #{current_path}; #{rake} #{cmd}"
end