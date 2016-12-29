require 'sinatra'
require 'mongoid'
require_relative 'lib/api_helpers'
require_relative 'models/task_status'
require_relative 'models/task'

helpers ApiHelpers

# DB Setup
Mongoid.load! "mongoid.yml"

before do
  content_type :json
  authenticate
end

get "/api" do
end

# Create new task
post "/api/tasks" do
  manager_only_permissions("Only managers can create new tasks!")

  status = TaskStatus.find_or_create_by(status: TaskStatus::STATUSES[0])
  task = status.tasks.new(json_params)

  if task.save
    status 200
    { message: "Successfully created new task.", task: task }.to_json
  else
    status 422
    { errors: task.errors }.to_json
  end
end

# Delete task
delete "/api/tasks/:id" do |id|
  manager_only_permissions("Only managers can delete tasks!")

  begin
    status = TaskStatus.find_by("tasks._id": BSON::ObjectId(id))
    task = status.tasks.find(id)
  rescue
    halt 400, { message: 'Invalid task id' }.to_json
  end

  if task.destroy
    status 200
    { message: "Successfully deleted task.", task: task }.to_json
  else
    status 422
    { errors: task.errors }.to_json
  end
end

# Get new nearby tasks
get "/api/tasks" do
  driver_location = params[:location]
  halt 403, { message: "You need to provide location e.g. ?location=[38.3692939,27.093442]" }.to_json if driver_location.blank?

  loc_arr = driver_location.delete!("[]").split(",").map(&:to_f)

  begin
    tasks = TaskStatus.where(status: TaskStatus::STATUSES[0]).near("tasks.location": loc_arr).pluck(:tasks)
  rescue
    halt 400, { message: 'Invalid location' }.to_json
  end

  { tasks: tasks }.to_json
end

# Change task status
patch "/api/tasks/:id" do |id|
  driver_only_permissions("Only drivers can change task status!")

  mode = params[:mode]
  if mode.blank? and (mode != "pick" or mode != "finish")
    halt 403, { message: "You need to provide a valid operation mode e.g. ?mode=pick or ?mode=finish" }.to_json
  end

  begin
    status = TaskStatus.find_by("tasks._id": BSON::ObjectId(id))
    task = status.tasks.find(id)
  rescue
    halt 400, { message: 'Invalid task id' }.to_json
  end

  if mode == "pick"
    new_status = TaskStatus.find_or_create_by(status: TaskStatus::STATUSES[1])
  elsif mode == "finish"
    new_status = TaskStatus.find_or_create_by(status: TaskStatus::STATUSES[2])
  end

  new_task = new_status.tasks.new(name: task.name, location: task.location)

  if new_task.save
    task.destroy
    status 200
    { message: "Successfully changed task status to #{mode == 'pick' ? 'assigned' : 'done'}", task: new_task }.to_json
  else
    status 422
    { errors: new_task.errors }.to_json
  end
end