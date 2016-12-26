require_relative './spec_helper.rb'

describe "/API" do

  it "should get ok response on get" do
    get "/api"
    expect(last_response).to be_ok
  end

end