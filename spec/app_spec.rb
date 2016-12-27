require_relative './spec_helper.rb'
require_relative '../lib/role_tokens'

describe "App" do

  describe "Authentication" do
    let(:valid_access_token) { RoleTokens::TOKENS[:manager][0] }

    it "should deny access with invalid token" do
      get "/api"
      expect(last_response.status).to eq 403
    end

    it "should allow access with a valid token" do
      get "/api", nil, { 'HTTP_ACCESS_TOKEN' => valid_access_token }
      expect(last_response.status).to eq 200
    end

  end

end