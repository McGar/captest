# config/deploy.rb 
require "bundler/capistrano"
set :app_name,        'captest'
set :scm,             :git
set :repository,      "https://github.com/McGar/#{app_name}.git"
# set :branch,          "origin/master"
set :branch,          "master"
set :migrate_target,  :current
set :ssh_options,     { :forward_agent => true }
set :rails_env,       "production"
set :deploy_to,       "/var/www/rubydev.aicure.com/#{app_name}"
set :normalize_asset_timestamps, false
set :keep_releases,   10
set :user,            "cjiang"
set :scm_username,    "McGar"
set :password,        "20120313"
set :scm_passphrase,  "Mg1123581321"
# set :group,           "staff"
set :use_sudo,        true
# set :gateway, "rubydev.aicure.com"
# set :gateway, "204.13.110.73"
# role :app, [192.168.1.1,192.168.1.2] multiple servers
# role :web, "machine1.mydomain.com", "machine2.mydomain.com", "machine3.mydomain.com"
# role :app, "machine1.mydomain.com", "machine2.mydomain.com", "machine3.mydomain.com"
# role :db,  "db.mydomain.com"

role :web,    "rubydev.aicure.com"
role :app,    "rubydev.aicure.com"
role :db,     "rubydev.aicure.com", :primary => true

#set(:latest_release)  { fetch(:current_path) }
#set(:release_path)    { fetch(:current_path) }
#set(:current_release) { fetch(:current_path) }
#
#set(:current_revision)  { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
#set(:latest_revision)   { capture("cd #{current_path}; git rev-parse --short HEAD").strip }
#set(:previous_revision) { capture("cd #{current_path}; git rev-parse --short HEAD@{1}").strip }

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
# app_name = 'captest'

after "deploy", "deploy:cleanup"

namespace :deploy do



  #desc "Deploy your application"
  #
  #task :default do
  #  create_release_dir
  #  update
  #  restart
  #end
  #
  #task :create_release_dir, :except => {:no_release => true} do
  #  run "#{try_sudo} mkdir -p #{fetch :releases_path}"
  #end
  #
  #
  #desc "Setup your git-based deployment app"
  #task :setup, :except => { :no_release => true } do
  #  dirs = [deploy_to, shared_path, releases_path]
  #  dirs += shared_children.map { |d| File.join(shared_path, d) }
  #  run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
  #  run "sudo git clone #{repository} #{current_path}"
  #
  #end
  #
  #task :cold do
  #  update
  #  migrate
  #end
  #
  #task :update do
  #  transaction do
  #    update_code
  #  end
  #end
  #
  #desc "Update the deployed code."
  #task :update_code, :except => { :no_release => true } do
  #  # chmod make sure bundle install succeed
  #  # run "cd #{current_path}; cd ../; #{try_sudo} chmod -R 777 shared"
  #  run "#{try_sudo} chmod -R 777 #{shared_path}"
  #  run "#{try_sudo} chmod -R 777 #{current_path}"
  #  run "cd #{current_path};#{try_sudo} git fetch origin; #{try_sudo} git reset --hard #{branch}"
  #
  #  finalize_update
  #end
  #
  #
  #
  #desc "Update the database (overwritten to avoid symlink)"
  #task :migrations do
  #  transaction do
  #    update_code
  #  end
  #  migrate
  #  restart
  #end
  #
  #task :finalize_update, :except => { :no_release => true } do
  #  # chmod it back
  #  run "#{try_sudo} chmod -R 777 #{latest_release}" if fetch(:group_writable, true)
  #
  #  # mkdir -p is making sure that the directories are there for some SCM's that don't
  #  # save empty folders
  #  run <<-CMD
  #    #{try_sudo} rm -rf #{latest_release}/log #{latest_release}/public/system #{latest_release}/tmp/pids &&
  #    mkdir -p #{latest_release}/public &&
  #    mkdir -p #{latest_release}/tmp &&
  #    mkdir -p #{latest_release}/public/system &&
  #    mkdir -p #{latest_release}/tmp/pids &&
  #    mkdir -p #{shared_path}/pids &&
  #    ln -s #{shared_path}/log #{latest_release}/log &&
  #    ln -s #{shared_path}/public/system #{latest_release}/public/system &&
  #    ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
  #    ln -sf #{latest_release}/config/database.yml #{shared_path}/database.yml
  #  CMD
  #
  #  if fetch(:normalize_asset_timestamps, true)
  #    stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
  #    asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
  #    run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
  #  end
  #end
  #
  #
  #namespace :rollback do
  #  desc "Moves the repo back to the previous version of HEAD"
  #  task :repo, :except => { :no_release => true } do
  #    set :branch, "HEAD@{1}"
  #    deploy.default
  #  end
  #
  #  desc "Rewrite reflog so HEAD@{1} will continue to point to at the next previous release."
  #  task :cleanup, :except => { :no_release => true } do
  #    run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
  #  end
  #
  #  desc "Rolls back to the previously deployed version."
  #  task :default do
  #    rollback.repo
  #    rollback.cleanup
  #  end
  #end

  # Self-defined way for first time deployments database update
  desc "Update code and then update database"
  task :migrations_with_update_code do
    transaction do
      update_code
    end
    migrate
  end

  desc "Update the database only, for the first time after setup."
  task :migrations_only do
    migrate
  end


  desc "Get permissions fixed"
  task :fix_permissions do
    run "cd #{deploy_to}; #{try_sudo} chmod -R 777 *"
    #run "#{try_sudo} chmod -R 777 #{shared_path}"
    #run "#{try_sudo} chmod -R 777 #{current_path}"
    #run "#{try_sudo} chmod -R 777 #{release_path}"
  end

  # Overwritten tasks
  task :default do
    update
    migrate
    restart
  end

  desc <<-DESC
    [internal] Touches up the released code. This is called by update_code \
    after the basic deploy finishes. It assumes a Rails project was deployed, \
    so if you are deploying something else, you may want to override this \
    task with your own environment's requirements.

    This task will make the release group-writable (if the :group_writable \
    variable is set to true, which is the default). It will then set up \
    symlinks to the shared directory for the log, system, and tmp/pids \
    directories, and will lastly touch all assets in public/images, \
    public/stylesheets, and public/javascripts so that the times are \
    consistent (so that asset timestamping works).  This touch process \
    is only carried out if the :normalize_asset_timestamps variable is \
    set to true, which is the default The asset directories can be overridden \
    using the :public_children variable.
  DESC
  task :finalize_update, :except => { :no_release => true } do
    escaped_release = latest_release.to_s.shellescape
    commands = []
    commands << "#{try_sudo} chmod -R -- g+w #{escaped_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't
    # save empty folders
    shared_children.map do |dir|
      d = dir.shellescape
      if (dir.rindex('/')) then
        commands += ["#{try_sudo} rm -rf -- #{escaped_release}/#{d}",
                     "#{try_sudo} mkdir -p -- #{escaped_release}/#{dir.slice(0..(dir.rindex('/'))).shellescape}"]
      else
        commands << "#{try_sudo} rm -rf -- #{escaped_release}/#{d}"
      end
      commands << "#{try_sudo} ln -s -- #{shared_path}/#{dir.split('/').last.shellescape} #{escaped_release}/#{d}"
    end

    run commands.join(' && ') if commands.any?

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = fetch(:public_children, %w(images stylesheets javascripts)).map { |p| "#{escaped_release}/public/#{p}" }
      run("find #{asset_paths.join(" ")} -exec touch -t #{stamp} -- {} ';'; true",
          :env => { "TZ" => "UTC" }) if asset_paths.any?
    end
  end



  desc <<-DESC
    Updates the symlink to the most recently deployed version. Capistrano works \
    by putting each new release of your application in its own directory. When \
    you deploy a new version, this task's job is to update the `current' symlink \
    to point at the new version. You will rarely need to call this task \
    directly; instead, use the `deploy' task (which performs a complete \
    deploy, including `restart') or the 'update' task (which does everything \
    except `restart').
  DESC
  task :create_symlink, :except => { :no_release => true } do
    on_rollback do
      if previous_release
        run "#{try_sudo} rm -f #{current_path}; #{try_sudo} ln -s #{previous_release} #{current_path}; true"
      else
        logger.important "no previous release to rollback to, rollback of symlink skipped"
      end
    end

    run "#{try_sudo} rm -f #{current_path} && #{try_sudo} ln -s #{latest_release} #{current_path}"
  end

  namespace :rollback do
    desc <<-DESC
      [internal] Points the current symlink at the previous revision.
      This is called by the rollback sequence, and should rarely (if
      ever) need to be called directly.
    DESC
    task :revision, :except => { :no_release => true } do
      if previous_release
        run "#{try_sudo} rm #{current_path}; #{try_sudo} ln -s #{previous_release} #{current_path}"
      else
        abort "could not rollback the code because there is no prior release"
      end
    end

    desc <<-DESC
      [internal] Removes the most recently deployed release.
      This is called by the rollback sequence, and should rarely
      (if ever) need to be called directly.
    DESC
    task :cleanup, :except => { :no_release => true } do
      run "if [ `readlink #{current_path}` != #{current_release} ]; then #{try_sudo} rm -rf #{current_release}; fi"
    end

    desc <<-DESC
      Rolls back to the previously deployed version. The `current' symlink will \
      be updated to point at the previously deployed version, and then the \
      current release will be removed from the servers. You'll generally want \
      to call `rollback' instead, as it performs a `restart' as well.
    DESC
    task :code, :except => { :no_release => true } do
      revision
      cleanup
    end

    desc <<-DESC
      Rolls back to a previous version and restarts. This is handy if you ever \
      discover that you've deployed a lemon; `cap rollback' and you're right \
      back where you were, on the previously deployed version.
    DESC
    task :default do
      revision
      restart
      cleanup
    end
  end


  # Self-defined START, STOP, RESTART
  desc "Zero-downtime restart of Unicorn"
  task :restart, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat /tmp/unicorn.#{app_name}.pid`"
  end

  desc "Start unicorn"
  task :start, :except => { :no_release => true } do
    # use rvmsudo instead of sudo, and make sure rvmsudo can work
    run "cd #{current_path} ;#{try_sudo} touch newfile; rvmsudo bundle exec unicorn_rails -l 8081 -c config/unicorn.rb -E #{rails_env} -D; #{try_sudo} rm newfile"
  end

  desc "Stop unicorn"
  task :stop, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat /tmp/unicorn.#{app_name}.pid`"
  end

end

def run_rake(cmd)
  run "cd #{current_path}; #{rake} #{cmd}"
end