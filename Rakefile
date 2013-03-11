#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Captest::Application.load_tasks


desc "Auto start unicorn for this app"
task :start_unicorn => :environment do
  # require "bundler/capistrano"
  path = "#{Rails.root}"
  port_id = 8081
  rails_env = "production"

  # echo secretPasswd | sudo -S service squid3 restart
  # run "cd #{path} ; #{try_sudo} touch newfile; rvmsudo bundle exec unicorn_rails -l #{port_id} -c config/unicorn.rb -E #{rails_env} -D; #{try_sudo} rm newfile"
  system "cd #{path}"
  # echo password need modification according to the deployer set in deploy.rb

  system "echo 20120313 | rvmsudo bundle exec unicorn_rails -l #{port_id} -c config/unicorn.rb -E #{rails_env} -D"

end