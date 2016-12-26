require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'json'
require 'database_cleaner'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end