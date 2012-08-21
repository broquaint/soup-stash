source 'https://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem 'sqlite3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'bootstrap-sass'

gem 'devise'
gem 'cancan'  # https://github.com/ryanb/cancan TODO - Use in anger.

gem 'bson_ext'
gem 'mongoid', "~> 3.0.0" # http://mongoid.org/docs/installation.html

gem 'kaminari'

# http://railsapps.github.com/tutorial-rails-mongoid-devise.html
# "Adding RSpec for Unit Testing"
gem 'rspec-rails', :group => [:development, :test]

# This hasn't been updated for mongoid 3 yet, not using it in anger so meh.
# gem 'mongoid-rspec', :group => :test

# "Cucumber Gems"
group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'

  gem 'cucumber-rails'
  gem 'capybara'
  gem 'database_cleaner'
end

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
