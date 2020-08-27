class User < ApplicationRecord
  include TimeTrackerExtension::UserExtension

  SUPPORTED_LANGUAGES = %w(en ru)
  has_secure_password validations: false

  has_many :time_records, dependent: :destroy
  has_many :users_workspaces
  has_many :workspaces, -> { distinct }, through: :users_workspaces
  has_and_belongs_to_many :projects, -> { distinct }
  belongs_to :active_workspace, class_name: "Workspace",
                                foreign_key: "active_workspace_id"

  def role(workspace_id = nil)
    workspace_settings(workspace_id).role
  end

  def admin?
    role == 'admin'
  end

  def owner?
    role == 'owner'
  end

  def notification_settings(workspace_id = nil)
    workspace_settings(workspace_id).notification_rules
  end

  def workspace_owner?(workspace_id)
    role(workspace_id) == 'owner'
  end

  def workspace_settings(workspace_id = nil)
    workspace_id ||= active_workspace_id
    users_workspaces.find_by(workspace_id: workspace_id)
  end
end
