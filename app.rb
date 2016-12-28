require 'sinatra'
require 'mongoid'
require_relative 'lib/api_helpers'

helpers ApiHelpers

# DB Setup
Mongoid.load! "mongoid.yml"

before do
  content_type :json
  authenticate!
end

get "/api" do
  "ok".to_json
end