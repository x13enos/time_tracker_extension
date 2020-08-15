json.array! @time_locking_rules do |rule|
  json.(rule, :id, :period)
end
