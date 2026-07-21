require 'rails_helper'

RSpec.describe 'Api::V1::Comments', type: :request do
  describe 'POST /api/v1/support_requests/:support_request_id/comments' do
    let!(:member) { create(:team_member, :developer) }
    let!(:support_request) { create(:support_request, status: :open, creator: member, team: member) }

    it 'creates a new comment with author_name' do
      expect {
        post "/api/v1/support_requests/#{support_request.id}/comments", params: {
          comment: { body: "This is a valid comment with enough length", team_member_id: member.id }
        }
      }.to change(Comment, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['body']).to eq('This is a valid comment with enough length')
      expect(json['author_name']).to eq(member.name)
      expect(json['support_request_id']).to eq(support_request.id)
    end

    it 'returns 404 when support request does not exist' do
      post '/api/v1/support_requests/999/comments', params: {
        comment: { body: "Test comment body here", team_member_id: member.id }
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Not found')
    end

    it 'returns 422 when body is missing' do
      post "/api/v1/support_requests/#{support_request.id}/comments", params: {
        comment: { team_member_id: member.id }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
      expect(json['details']).to include("Body can't be blank")
    end

    it 'returns 422 when body is too short' do
      post "/api/v1/support_requests/#{support_request.id}/comments", params: {
        comment: { body: "Short", team_member_id: member.id }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
    end

    it 'can add comment to a closed request' do
      closed_request = create(:support_request, status: :open, creator: member, team: member)
      create(:comment, support_request: closed_request, team_member: member, body: "A comment to allow resolve")
      closed_request.update!(status: :closed)

      post "/api/v1/support_requests/#{closed_request.id}/comments", params: {
        comment: { body: "Comment on closed request body", team_member_id: member.id }
      }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['author_name']).to eq(member.name)
    end
  end
end
