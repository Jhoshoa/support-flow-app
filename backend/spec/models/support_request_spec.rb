require 'rails_helper'

RSpec.describe SupportRequest, type: :model do
  describe 'validations' do
    subject { build(:support_request) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:priority) }
    it { should validate_presence_of(:creator) }
    it { should validate_presence_of(:team) }
  end

  describe 'enums' do
    it 'defines status enum' do
      expect(SupportRequest.statuses).to eq({
        'open' => 0,
        'in_progress' => 1,
        'resolved' => 2,
        'closed' => 3
      })
    end

    it 'defines priority enum' do
      expect(SupportRequest.priorities).to eq({
        'low' => 0,
        'medium' => 1,
        'high' => 2,
        'critical' => 3
      })
    end
  end

  describe 'associations' do
    it { should belong_to(:creator).class_name('TeamMember') }
    it { should belong_to(:assignee).class_name('TeamMember').optional }
    it { should belong_to(:team).class_name('TeamMember') }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe 'business rules' do
    it 'cannot be resolved without comments' do
      request = create(:support_request, :open)
      request.status = :resolved
      expect(request).not_to be_valid
      expect(request.errors[:status]).to include("can't be resolved without at least one comment")
    end

    it 'can be resolved when it has comments' do
      request = create(:support_request, :open)
      create(:comment, support_request: request)
      request.status = :resolved
      expect(request).to be_valid
    end

    it 'can be closed without comments' do
      request = create(:support_request, :open)
      request.status = :closed
      expect(request).to be_valid
    end
  end

  describe 'factory' do
    it 'has a valid default factory' do
      expect(build(:support_request)).to be_valid
    end

    it 'has resolved trait with comment' do
      request = build(:support_request, :resolved)
      expect(request.comments.size).to eq(1)
      expect(request.status).to eq('resolved')
    end

    it 'has closed trait with comment' do
      request = build(:support_request, :closed)
      expect(request.comments.size).to eq(1)
      expect(request.status).to eq('closed')
    end

    it 'has critical trait' do
      expect(build(:support_request, :critical).priority).to eq('critical')
    end
  end
end
