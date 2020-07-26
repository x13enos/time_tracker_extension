class Workspace < ApplicationRecord
  include TimeTrackerExtension::WorkspaceExtension

  has_and_belongs_to_many :users, -> { distinct }
  has_many :projects, dependent: :destroy
  has_many :time_records, through: :projects

end
