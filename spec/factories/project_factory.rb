FactoryBot.define do

  factory :project do
    name     { Faker::Company.name }
    association :workspace
  end

end
