class User < ApplicationRecord
  include TimeTrackerExtension::UserExtension

  SUPPORTED_LANGUAGES = %w(en ru)
  has_secure_password validations: false

  enum role: [:admin, :staff]

  validates :email, :locale, :active_workspace_id, presence: true
  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { in: 8..32 }, allow_nil: true
  validates :locale, inclusion: { in: SUPPORTED_LANGUAGES,
    message: I18n.t("users.errors.locale_inclusion") }

  has_one :notification_settings
  has_many :users_workspaces
  has_many :workspaces, -> { distinct }, through: :users_workspaces
  belongs_to :active_workspace, class_name: "Workspace",
                                foreign_key: "active_workspace_id"

  def role(workspace_id = nil)
    workspace_id ||= active_workspace_id
    users_workspaces.find_by(workspace_id: workspace_id).role
  end

  def admin?
    role == 'admin'
  end

  def owner?
    role == 'owner'
  end

  def owner_for_workspace?(workspace_id)
    role(workspace_id) == 'owner'
  end
end
