require 'sinatra'
require 'mongoid'

# DB Setup
Mongoid.load! "mongoid.yml"

before do
  content_type :json
end

get "/api" do
  "Test".to_json
end