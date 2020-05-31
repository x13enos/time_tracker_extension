json.time_records @time_records do |time_record|
  json.(time_record, :id, :description, :project_id, :tag_ids)
  json.assigned_date time_record.assigned_date.strftime("%d/%m/%Y")
  json.time_start time_record.time_start_as_epoch
  json.spent_time time_record.calculated_spent_time
end

json.blocked_days @blocked_days.map{|p| p.strftime("%d/%m/%Y") }
