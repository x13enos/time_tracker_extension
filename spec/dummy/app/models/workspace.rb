class Workspace < ApplicationRecord
  include TimeTrackerExtension::WorkspaceExtension

  has_many :users_workspaces
  has_many :users, -> { distinct }, through: :users_workspaces
  has_many :projects, dependent: :destroy
  has_many :time_records, through: :projects

end
