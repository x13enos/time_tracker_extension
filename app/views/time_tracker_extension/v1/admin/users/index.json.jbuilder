json.array! @users do |user|
  json.(user, :id, :name, :email)
  json.role user.role(@current_workspace_id)
end
