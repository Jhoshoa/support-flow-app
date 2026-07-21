FactoryBot.define do
  factory :team_member do
    sequence(:name) { |n| "Member #{n}" }
    sequence(:email) { |n| "member#{n}@supportflow.dev" }
    role { :developer }
    active { true }

    trait :developer do
      role { :developer }
    end

    trait :qa do
      role { :qa }
    end

    trait :support do
      role { :support }
    end

    trait :inactive do
      active { false }
    end
  end
end
