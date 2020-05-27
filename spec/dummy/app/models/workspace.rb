class Workspace < ApplicationRecord
  include TimeTrackerExtension::WorkspaceExtension

  has_and_belongs_to_many :users, -> { distinct }
end
