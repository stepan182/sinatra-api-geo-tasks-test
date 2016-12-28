require_relative '../spec_helper.rb'
require_relative '../../models/task_status'
require_relative '../../models/task'

RSpec.describe TaskStatus, type: :model do

  describe "Associations" do
    it "has many embeded tasks" do
      assc = described_class.reflect_on_association(:tasks)
      expect(assc.macro).to eq :embeds_many
    end
  end

  describe "Validations" do
    let(:task_status) { TaskStatus.new(status: TaskStatus::STATUSES[0]) }

    it "is valid with valid attributes" do
      expect(task_status).to be_valid
    end

    it "status should be a String" do
      expect(task_status.status).to be_a(String)
    end

    it "is not valid without a status" do
      task_status.status = nil
      expect(task_status).to_not be_valid
    end

    it "is not valid without a proper status" do
      task_status.status = "test"
      expect(task_status).to_not be_valid
    end

    it "should only have unique statuses" do
      status = TaskStatus.create(status: TaskStatus::STATUSES[0])
      expect(task_status).to_not be_valid
    end

  end

end