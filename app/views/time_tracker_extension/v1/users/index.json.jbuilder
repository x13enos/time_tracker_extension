json.array! @users do |user|
  json.(user, :id, :name, :role, :email)
end
