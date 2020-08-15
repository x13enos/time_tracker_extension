FactoryBot.define do

  factory :user do

    after(:create) do |object|
      object.active_workspace.users << object
      if object.notification_settings.nil?
        object.create_notification_settings
      end
    end

    name     { Faker::Name.name }
    email    { Faker::Internet.unique.email }
    password { "password" }
    association :active_workspace, factory: :workspace

    trait :owner do
      after(:create) do |object|
        object.users_workspaces.first.update(role: :owner)
      end
    end

    trait :admin do
      after(:create) do |object|
        object.users_workspaces.first.update(role: :admin)
      end
    end

    trait :staff do
      after(:create) do |object|
        object.users_workspaces.first.update(role: :staff)
      end
    end
  end

end
