json.partial! 'time_tracker_extension/v1/users/show', locals: { user: user }
json.workspaces user.workspaces, :id, :name
