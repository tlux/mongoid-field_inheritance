require 'rubygems'
require 'bundler/setup'
require 'mongoid'
require 'mongoid/field_inheritance'
require 'rspec'
require 'pry-byebug'

Mongoid.configure do |config|
  config.connect_to('mongoid_field_inheritance_test')
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.after :each do
    Mongoid.purge!
  end
end
