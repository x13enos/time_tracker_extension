class UsersWorkspace < ApplicationRecord
  enum role: { owner: 0, admin: 1, staff: 2}

  belongs_to :workspace
  belongs_to :user
end
