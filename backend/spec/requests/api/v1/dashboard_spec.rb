require 'rails_helper'

RSpec.describe 'Api::V1::Dashboard', type: :request do
  describe 'GET /api/v1/dashboard' do
    before do
      member = create(:team_member, :developer)
      support_member = create(:team_member, :support)

      create(:support_request, status: :open, priority: :high, creator: support_member, team: member)
      create(:support_request, status: :open, priority: :critical, creator: support_member, team: member)
      create(:support_request, status: :in_progress, priority: :medium, creator: support_member, team: member, assignee: member)
      resolved = create(:support_request, status: :open, priority: :low, creator: support_member, team: member)
      create(:comment, support_request: resolved, team_member: member, body: "A comment to allow resolve")
      resolved.update!(status: :resolved)
    end

    it 'returns dashboard metrics' do
      get '/api/v1/dashboard'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['total_requests']).to eq(4)
      expect(json['requests_by_status']).to eq({
        'open' => 2,
        'in_progress' => 1,
        'resolved' => 1
      })
      expect(json['requests_by_priority']).to eq({
        'high' => 1,
        'critical' => 1,
        'medium' => 1,
        'low' => 1
      })
    end

    it 'returns team request counts' do
      get '/api/v1/dashboard'

      json = JSON.parse(response.body)
      expect(json['requests_by_team']).to be_an(Array)
      expect(json['requests_by_team'].size).to be >= 1
    end
  end
end
