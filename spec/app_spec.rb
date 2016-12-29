require_relative './spec_helper.rb'
require_relative '../lib/role_tokens'

RSpec.describe "App" do
  let(:manager_access_token) { RoleTokens::TOKENS[:manager][0] }
  let(:driver_access_token) { RoleTokens::TOKENS[:driver][0] }

  describe "Authentication" do

    it "should deny access with invalid token" do
      get "/api"
      expect(last_response.status).to eq 403
    end

    it "should allow access with a valid token" do
      get "/api", nil, { 'HTTP_ACCESS_TOKEN' => manager_access_token }
      expect(last_response.status).to eq 200
    end

  end

  describe "Create new task" do
    let(:valid_json) { {name: "test", location: [0.0, 0.0]}.to_json }

    it "should allow access only to the managers" do
      post "/api/tasks", valid_json, { 'HTTP_ACCESS_TOKEN' => manager_access_token }
      expect(last_response.status).to eq 200
    end

    it "should deny access to drivers" do
      post "/api/tasks", valid_json, { 'HTTP_ACCESS_TOKEN' => driver_access_token }
      expect(last_response.status).to eq 403
    end

    it "should allow only valid json body" do
      post "/api/tasks", nil, { 'HTTP_ACCESS_TOKEN' => manager_access_token }
      expect(last_response.status).to eq 400
    end

    it "should create new task" do
      post "/api/tasks", valid_json, { 'HTTP_ACCESS_TOKEN' => manager_access_token }
      expect(last_response.status).to eq 200
    end

    it "should trow errors on invalid task attributes" do
      post "/api/tasks", {name: nil, location: nil}.to_json, { 'HTTP_ACCESS_TOKEN' => manager_access_token }
      expect(last_response.status).to eq 422
    end

  end

  describe "Delete task" do
    let(:status) { TaskStatus.find_or_create_by!(status: TaskStatus::STATUSES[0]) }
    let(:task) { status.tasks.create!(name: "test", location: [0.0, 0.0]) }

    it "should allow access only to the managers and delete task" do
      delete "/api/tasks/#{task._id}", nil, { 'HTTP_ACCESS_TOKEN' => manager_access_token } do |id|
        expect(last_response.status).to eq 200
      end
    end

    it "should deny access to drivers" do
      delete "/api/tasks/#{task._id}", nil, { 'HTTP_ACCESS_TOKEN' => driver_access_token } do |id|
        expect(last_response.status).to eq 403
      end
    end

  end

  describe "Get tasks" do

    it "should requires location param" do
      get "/api/tasks", nil, { 'HTTP_ACCESS_TOKEN' => driver_access_token }
      expect(last_response.status).to eq 403
    end

    it "should list tasks" do
      get "/api/tasks", {location: "[38.3692939,27.093442]"}, { 'HTTP_ACCESS_TOKEN' => driver_access_token }
      expect(last_response.status).to eq 200
    end

  end

  describe "Update task status" do
    let(:status) { TaskStatus.find_or_create_by!(status: TaskStatus::STATUSES[0]) }
    let(:task) { status.tasks.create!(name: "test", location: [0.0, 0.0]) }

    it "should requires mode param" do
      patch "/api/tasks/#{task._id}", nil, { 'HTTP_ACCESS_TOKEN' => driver_access_token }
      expect(last_response.status).to eq 403
    end

    it "should allow access only to the drivers" do
      patch "/api/tasks/#{task._id}", {mode: "pick"}, { 'HTTP_ACCESS_TOKEN' => driver_access_token } do |id|
        expect(last_response.status).to eq 200
      end
    end

    it "should deny access to the managers" do
      patch "/api/tasks/#{task._id}", {mode: "pick"}, { 'HTTP_ACCESS_TOKEN' => manager_access_token } do |id|
        expect(last_response.status).to eq 403
      end
    end

    it "should update task status to assigned in pick mode" do
      patch "/api/tasks/#{task._id}", {mode: "pick"}, { 'HTTP_ACCESS_TOKEN' => driver_access_token } do |id|
        expect(last_response.status).to eq 200
      end
    end

    it "should update task status to done in finish mode" do
      patch "/api/tasks/#{task._id}", {mode: "finish"}, { 'HTTP_ACCESS_TOKEN' => driver_access_token } do |id|
        expect(last_response.status).to eq 200
      end
    end

  end

end