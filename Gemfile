source 'https://rubygems.org'

gem 'rails', '3.2.3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'underscore-rails'
gem 'bootstrap-sass'

gem 'markdown-rails'

gem 'rabl'

gem 'devise'
gem 'cancan'  # https://github.com/ryanb/cancan TODO - Use in anger.

gem 'bson_ext'
gem 'mongoid', "~> 3.0.0" # http://mongoid.org/docs/installation.html
gem 'hashie'

gem 'kaminari', ">= 0.14.0"
gem 'kaminari-bootstrap'

# Needed by the log parser
gem 'slop'
gem 'net-http-follow_tail'

# Used by soupstash/ingestlogfile
gem 'json'

# http://railsapps.github.com/tutorial-rails-mongoid-devise.html
# "Adding RSpec for Unit Testing"
gem 'rspec-rails', '>= 2.6.1', :group => [:development, :test]

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
