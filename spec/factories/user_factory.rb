FactoryBot.define do

  factory :user do

    after(:create) do |object|
      if object.notification_settings.nil?
        object.create_notification_settings
      end
    end
    
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
