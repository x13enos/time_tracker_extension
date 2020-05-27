FactoryBot.define do

  factory :user do
    name     { Faker::Name.name }
    email    { Faker::Internet.unique.email }
    password { "password" }
    association :active_workspace, factory: :workspace

    trait :admin do
      role { :admin }
      id { 100 }
    end

    trait :staff do
      role { :staff }
      id { 101 }
    end
  end

end

