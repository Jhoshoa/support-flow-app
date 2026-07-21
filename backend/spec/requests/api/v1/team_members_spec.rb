require 'rails_helper'

RSpec.describe 'Api::V1::TeamMembers', type: :request do
  describe 'GET /api/v1/team_members' do
    before do
      create(:team_member, name: "Alice", email: "alice@test.com", role: :developer)
      create(:team_member, name: "Bob", email: "bob@test.com", role: :support)
    end

    it 'returns all team members ordered by name' do
      get '/api/v1/team_members'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['team_members'].size).to eq(2)
      expect(json['team_members'].map { |m| m['name'] }).to eq(["Alice", "Bob"])
    end

    it 'returns correct fields for each member' do
      get '/api/v1/team_members'

      json = JSON.parse(response.body)
      member = json['team_members'].first
      expect(member).to include('id', 'name', 'email', 'role', 'active', 'created_at', 'updated_at')
      expect(member['role']).to eq('developer')
      expect(member['active']).to be true
    end

    it 'returns empty array when no members exist' do
      TeamMember.delete_all
      get '/api/v1/team_members'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['team_members']).to eq([])
    end
  end

  describe 'POST /api/v1/team_members' do
    let(:valid_params) do
      {
        team_member: {
          name: "Charlie",
          email: "charlie@test.com",
          role: "support"
        }
      }
    end

    it 'creates a new team member' do
      expect {
        post '/api/v1/team_members', params: valid_params
      }.to change(TeamMember, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('Charlie')
      expect(json['email']).to eq('charlie@test.com')
      expect(json['role']).to eq('support')
      expect(json['active']).to be true
    end

    it 'returns 422 when name is missing' do
      post '/api/v1/team_members', params: {
        team_member: { email: "test@test.com", role: "developer" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
      expect(json['details']).to include("Name can't be blank")
    end

    it 'returns 422 when email is invalid' do
      post '/api/v1/team_members', params: {
        team_member: { name: "Test", email: "not-an-email", role: "developer" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
      expect(json['details']).to include("Email is invalid")
    end

    it 'returns 422 when email is already taken' do
      create(:team_member, email: "existing@test.com")

      post '/api/v1/team_members', params: {
        team_member: { name: "Test", email: "existing@test.com", role: "developer" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
      expect(json['details']).to include("Email has already been taken")
    end
  end

  describe 'PATCH /api/v1/team_members/:id' do
    let!(:member) { create(:team_member, name: "Original Name") }

    it 'updates the team member' do
      patch "/api/v1/team_members/#{member.id}", params: {
        team_member: { name: "Updated Name" }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['name']).to eq('Updated Name')
    end

    it 'can deactivate a member' do
      patch "/api/v1/team_members/#{member.id}", params: {
        team_member: { active: false }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['active']).to be false
    end

    it 'returns 404 when member does not exist' do
      patch '/api/v1/team_members/999', params: {
        team_member: { name: "Test" }
      }

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Not found')
      expect(json['details']).to be_an(Array)
    end

    it 'returns 422 when email is duplicate' do
      other = create(:team_member, email: "other@test.com")

      patch "/api/v1/team_members/#{member.id}", params: {
        team_member: { email: "other@test.com" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Validation failed')
    end
  end
end
