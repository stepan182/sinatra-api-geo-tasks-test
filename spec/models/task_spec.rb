require_relative '../spec_helper.rb'
require_relative '../../models/task_status'
require_relative '../../models/task'

RSpec.describe Task, type: :model do

  describe "Associations" do
    it "is embedded_in task_status" do
      assc = described_class.reflect_on_association(:task_status)
      expect(assc.macro).to eq :embedded_in
    end
  end

  describe "Validations" do
    let(:task) { Task.new(name: "test", location: [38.3692939, 27.093442]) }

    it "is valid with valid attributes" do
      expect(task).to be_valid
    end

    it "name should be a String" do
      expect(task.name).to be_a(String)
    end

    it "location should be an Array" do
      expect(task.location).to be_a(Array)
    end

    it "is not valid without a name" do
      task.name = nil
      expect(task).to_not be_valid
    end

    it "is not valid without a location" do
      task.location = nil
      expect(task).to_not be_valid
    end

  end

end