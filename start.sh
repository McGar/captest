# setuid cjiang  # set to the user, which should run the app
PATH = $PATH
rvmsudo bundle exec unicorn_rails -l 8081 -c /var/www/rubydev.aicure.com/captest/current/config/unicorn.rb -E production -D