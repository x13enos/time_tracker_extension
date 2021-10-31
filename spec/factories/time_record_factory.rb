FactoryBot.define do

  factory :time_record do
    description { Faker::Lorem.word }
    assigned_date { Date.today }
    association :user
    association :project
    association :workspace
    spent_time { 0.25 }
  end

end
