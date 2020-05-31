module TimeRecords
  class BaseForm
    include ActiveModel::Model
    include TimeTrackerExtension::TimeRecords::BaseFormExtension

    validates :description, :spent_time, :assigned_date, presence: true

    ATTRIBUTES = %w[name spent_time time_start description assigned_date
                 project_id user_id created_at updated_at tag_ids]

    attr_accessor *ATTRIBUTES
    attr_accessor :id, :user, :time_record
  end
end
