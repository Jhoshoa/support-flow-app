require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe 'validations' do
    subject { build(:comment) }

    it { should validate_presence_of(:body) }
  end

  describe 'associations' do
    it { should belong_to(:support_request) }
    it { should belong_to(:team_member) }
  end

  describe 'factory' do
    it 'has a valid default factory' do
      expect(build(:comment)).to be_valid
    end
  end
end
