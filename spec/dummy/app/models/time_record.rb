class TimeRecord < ApplicationRecord

  belongs_to :user
  belongs_to :project, optional: true
  belongs_to :workspace
  has_and_belongs_to_many :tags, -> { distinct }

  scope :by_workspace, ->(workspace_id) { joins(:project).where("projects.workspace_id = ?", workspace_id) }

  def staff?
  end

  def active?
    time_start.present?
  end

  def calculated_spent_time
    if active?
      passed_time_from_start = (Time.now - time_start) / 3600
      (passed_time_from_start + spent_time).round(2)
    else
      spent_time
    end
  end
end
