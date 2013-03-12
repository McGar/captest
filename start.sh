# setuid cjiang  # set to the user, which should run the app
rvmsudo bundle exec unicorn_rails -l 8081 -c config/unicorn.rb -E production -D