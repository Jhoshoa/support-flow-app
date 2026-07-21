module Api
  module V1
    class TeamMembersController < ApplicationController
      def index
        team_members = TeamMember.all.order(:name)
        render json: { team_members: team_members.map { |m| serialize_member(m) } }
      end

      def create
        team_member = TeamMember.create!(team_member_params)
        render json: serialize_member(team_member), status: :created
      end

      def update
        team_member = TeamMember.find(params[:id])
        team_member.update!(team_member_params)
        render json: serialize_member(team_member)
      end

      private

      def team_member_params
        params.require(:team_member).permit(:name, :email, :role, :active)
      end

      def serialize_member(member)
        {
          id: member.id,
          name: member.name,
          email: member.email,
          role: member.role,
          active: member.active,
          created_at: member.created_at,
          updated_at: member.updated_at
        }
      end
    end
  end
end
