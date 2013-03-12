  setuid cjiang  # set to the user, which should run the app
  exec echo 20120313 | sudo touch finished_running_unicorn
  exec echo 20120313 | rvmsudo bundle exec unicorn_rails -l 8081 -c config/unicorn.rb -E production -D