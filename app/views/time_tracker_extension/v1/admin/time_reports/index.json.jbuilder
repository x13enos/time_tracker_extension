json.array! @periods do |period|
  json.id period.id
  json.approved period.approved
  json.from period.beginning_of_period.strftime("%d/%m/%Y")
  json.to period.end_of_period.strftime("%d/%m/%Y")
end
