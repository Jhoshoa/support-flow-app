require 'rails_helper'

RSpec.describe 'Api::V1::SupportRequests', type: :request do
  describe 'GET /api/v1/support_requests' do
    let!(:developer) { create(:team_member, :developer) }
    let!(:support_member) { create(:team_member, :support) }

    let!(:open_request) { create(:support_request, status: :open, priority: :high, creator: support_member, team: developer) }
    let!(:in_progress_request) { create(:support_request, status: :in_progress, priority: :medium, creator: support_member, team: developer, assignee: developer) }
    let!(:resolved_request) do
      sr = create(:support_request, status: :open, priority: :low, creator: support_member, team: developer)
      create(:comment, support_request: sr, team_member: developer)
      sr.update!(status: :resolved, resolved_at: 1.day.ago)
      sr
    end

    it 'returns all support requests ordered by created_at desc' do
      get '/api/v1/support_requests'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].size).to eq(3)
      ids = json['support_requests'].map { |r| r['id'] }
      expect(ids).to eq([resolved_request.id, in_progress_request.id, open_request.id])
    end

    it 'returns correct fields' do
      get '/api/v1/support_requests'

      json = JSON.parse(response.body)
      sr = json['support_requests'].first
      expect(sr).to include('id', 'title', 'description', 'status', 'priority', 'assignee', 'comments_count')
    end

    it 'filters by status' do
      get '/api/v1/support_requests', params: { status: 'open' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].size).to eq(1)
      expect(json['support_requests'].first['status']).to eq('open')
    end

    it 'filters by priority' do
      get '/api/v1/support_requests', params: { priority: 'high' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].size).to eq(1)
      expect(json['support_requests'].first['priority']).to eq('high')
    end

    it 'filters by team_member_id (assigned)' do
      get '/api/v1/support_requests', params: { team_member_id: developer.id }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].size).to eq(1)
      expect(json['support_requests'].first['assignee']['id']).to eq(developer.id)
    end

    it 'filters unassigned requests' do
      get '/api/v1/support_requests', params: { unassigned: 'true' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].size).to eq(2)
      expect(json['support_requests'].map { |r| r['id'] }).to include(open_request.id, resolved_request.id)
    end

    it 'filters by text search' do
      open_request.update!(title: "Database timeout issue")
      get '/api/v1/support_requests', params: { q: 'timeout' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].size).to eq(1)
      expect(json['support_requests'].first['title']).to include('timeout')
    end

    it 'combines multiple filters' do
      get '/api/v1/support_requests', params: { status: 'open', priority: 'high' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests'].size).to eq(1)
      expect(json['support_requests'].first['status']).to eq('open')
      expect(json['support_requests'].first['priority']).to eq('high')
    end

    it 'returns empty array when no matches' do
      get '/api/v1/support_requests', params: { status: 'closed' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['support_requests']).to eq([])
    end
  end

  describe 'GET /api/v1/support_requests/:id' do
    let!(:member) { create(:team_member, :developer) }
    let!(:request_record) { create(:support_request, status: :open, creator: member, team: member) }

    it 'returns the support request with comments' do
      create(:comment, support_request: request_record, team_member: member, body: "First comment here")
      create(:comment, support_request: request_record, team_member: member, body: "Second comment here")

      get "/api/v1/support_requests/#{request_record.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['id']).to eq(request_record.id)
      expect(json['comments'].size).to eq(2)
      expect(json['comments'].first['body']).to eq('First comment here')
    end

    it 'returns assignee details when assigned' do
      request_record.update!(assignee: member)
      get "/api/v1/support_requests/#{request_record.id}"

      json = JSON.parse(response.body)
      expect(json['assignee']['name']).to eq(member.name)
    end

    it 'returns null assignee when unassigned' do
      get "/api/v1/support_requests/#{request_record.id}"

      json = JSON.parse(response.body)
      expect(json['assignee']).to be_nil
    end

    it 'returns 404 when request does not exist' do
      get '/api/v1/support_requests/999'

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Not found')
    end
  end

  describe 'POST /api/v1/support_requests' do
    let!(:creator) { create(:team_member, :support) }
    let!(:team) { create(:team_member, :developer) }

    let(:valid_params) do
      {
        support_request: {
          title: "New bug report",
          description: "Something is broken",
          priority: "high",
          creator_id: creator.id,
          team_id: team.id
        }
      }
    end

    it 'creates a new support request' do
      expect {
        post '/api/v1/support_requests', params: valid_params
      }.to change(SupportRequest, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['title']).to eq('New bug report')
      expect(json['status']).to eq('open')
    end

    it 'creates with assignee' do
      assignee = create(:team_member, :developer)
      post '/api/v1/support_requests', params: {
        support_request: valid_params[:support_request].merge(assignee_id: assignee.id)
      }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['assignee']['id']).to eq(assignee.id)
    end

    it 'returns 422 when title is missing' do
      post '/api/v1/support_requests', params: {
        support_request: { description: "test", priority: "medium", creator_id: creator.id, team_id: team.id }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
      expect(json['details']).to include("Title can't be blank")
    end

    it 'returns 422 when creator is missing' do
      post '/api/v1/support_requests', params: {
        support_request: { title: "Test", description: "test", priority: "medium", team_id: team.id }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
    end
  end

  describe 'PATCH /api/v1/support_requests/:id' do
    let!(:member) { create(:team_member, :developer) }
    let!(:request_record) { create(:support_request, status: :open, creator: member, team: member) }

    it 'updates the status' do
      create(:comment, support_request: request_record, team_member: member, body: "A comment to allow resolve")
      patch "/api/v1/support_requests/#{request_record.id}", params: {
        support_request: { status: "resolved" }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['status']).to eq('resolved')
    end

    it 'can assign to a member' do
      assignee = create(:team_member, :developer)
      patch "/api/v1/support_requests/#{request_record.id}", params: {
        support_request: { assignee_id: assignee.id }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['assignee']['id']).to eq(assignee.id)
    end

    it 'returns 404 when request does not exist' do
      patch '/api/v1/support_requests/999', params: {
        support_request: { status: "resolved" }
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Not found')
    end

    it 'returns 422 when trying to resolve without comments' do
      patch "/api/v1/support_requests/#{request_record.id}", params: {
        support_request: { status: "resolved" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
      expect(json['details']).to include("Status can't be resolved without at least one comment")
    end
  end
end
