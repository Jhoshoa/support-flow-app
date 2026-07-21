module Api
  module V1
    class DashboardController < ApplicationController
      def index
        render json: {
          total_requests: SupportRequest.count,
          requests_by_status: SupportRequest.group(:status).count.transform_keys(&:to_s),
          requests_by_priority: SupportRequest.group(:priority).count.transform_keys(&:to_s),
          requests_by_team: team_request_counts
        }
      end

      private

      def team_request_counts
        TeamMember.left_joins(:created_requests)
          .group('team_members.id')
          .select('team_members.id, team_members.name, COUNT(support_requests.id) as request_count')
          .map { |m| { id: m.id, name: m.name, count: m.request_count } }
      end
    end
  end
end
