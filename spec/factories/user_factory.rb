FactoryBot.define do

  factory :user do

    before(:create) do |object|
      if object.active_workspace_id.nil?
        workspace = create(:workspace)
        object.active_workspace = workspace
      else
        object.workspaces << object.active_workspace
      end
    end

    name     { Faker::Name.name }
    email    { Faker::Internet.unique.email }
    password { "password" }
    timezone { "Europe/Kiev" }
    association :active_workspace, factory: :workspace
    telegram_token { SecureRandom.hex }

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
