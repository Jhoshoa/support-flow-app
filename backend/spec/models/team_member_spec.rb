require 'rails_helper'

RSpec.describe TeamMember, type: :model do
  describe 'validations' do
    subject { build(:team_member) }

    it { should validate_presence_of(:name) }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("not-an-email").for(:email) }

    it { should validate_presence_of(:role) }

    it 'has valid default attributes' do
      member = create(:team_member)
      expect(member.role).to eq('developer')
      expect(member.active).to be true
    end
  end

  describe 'enums' do
    it 'defines role enum with correct values' do
      expect(TeamMember.roles).to eq({
        'developer' => 0,
        'qa' => 1,
        'support' => 2
      })
    end
  end

  describe 'factory' do
    it 'has a valid default factory' do
      expect(build(:team_member)).to be_valid
    end

    it 'creates unique emails for each instance' do
      first = create(:team_member)
      second = create(:team_member)
      expect(first.email).not_to eq(second.email)
    end

    it 'has traits for each role' do
      expect(create(:team_member, :developer).role).to eq('developer')
      expect(create(:team_member, :qa).role).to eq('qa')
      expect(create(:team_member, :support).role).to eq('support')
    end

    it 'has inactive trait' do
      expect(create(:team_member, :inactive).active).to be false
    end
  end
end
