class TaskStatus
  include Mongoid::Document
  embeds_many :tasks

  STATUSES = ['new', 'assigned', 'done']

  field :status, type: String, default: STATUSES[0]

  validates_inclusion_of :status, in: STATUSES, message: "{{value}} must be in #{STATUSES.join ','}"
  validates_uniqueness_of :status
end