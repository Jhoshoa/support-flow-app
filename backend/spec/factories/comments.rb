FactoryBot.define do
  factory :comment do
    body { Faker::Lorem.paragraph }
    team_member { create(:team_member) }
    support_request { create(:support_request) }
  end
end
