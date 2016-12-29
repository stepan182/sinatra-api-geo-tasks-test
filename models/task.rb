class Task
  include Mongoid::Document
  embedded_in :task_status

  field :name, type: String
  field :location, type: Array

  index( { location: "2d" }, { min: -180, max: 180 })

  validates_presence_of :name, :location
end