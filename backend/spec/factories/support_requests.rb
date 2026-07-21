FactoryBot.define do
  factory :support_request do
    sequence(:title) { |n| "Support Request #{n}" }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    status { :open }
    priority { :medium }
    creator { create(:team_member, :support) }
    team { create(:team_member, :developer) }

    trait :open do
      status { :open }
    end

    trait :in_progress do
      status { :in_progress }
    end

    trait :resolved do
      status { :resolved }
      after(:build) do |request|
        request.comments << build(:comment, support_request: request)
      end
    end

    trait :closed do
      status { :closed }
      after(:build) do |request|
        request.comments << build(:comment, support_request: request)
      end
    end

    trait :with_assignee do
      assignee { create(:team_member, :developer) }
    end

    trait :critical do
      priority { :critical }
    end
  end
end
