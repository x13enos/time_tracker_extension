class TimeRecord < ApplicationRecord

  belongs_to :user
  belongs_to :project
  has_one :workspace, through: :project
  has_and_belongs_to_many :tags, -> { distinct }
  
end
