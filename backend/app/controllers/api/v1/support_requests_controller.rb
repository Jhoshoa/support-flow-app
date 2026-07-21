module Api
  module V1
    class SupportRequestsController < ApplicationController
      def index
        support_requests = filter_support_requests
        render json: { support_requests: support_requests.map { |r| serialize_request(r) } }
      end

      def show
        support_request = SupportRequest.includes(:assignee, :comments).find(params[:id])
        render json: serialize_request_detail(support_request)
      end

      def create
        support_request = SupportRequest.create!(support_request_params)
        render json: serialize_request_detail(support_request), status: :created
      end

      def update
        support_request = SupportRequest.find(params[:id])
        support_request.update!(support_request_params)
        render json: serialize_request(support_request)
      end

      private

      def support_request_params
        params.require(:support_request).permit(
          :title, :description, :status, :priority, :creator_id, :assignee_id, :team_id
        )
      end

      def filter_support_requests
        scope = SupportRequest.includes(:assignee)
        scope = scope.where(status: params[:status]) if params[:status].present?
        scope = scope.where(priority: params[:priority]) if params[:priority].present?
        scope = scope.where(assignee_id: params[:team_member_id]) if params[:team_member_id].present?
        scope = scope.where(assignee_id: nil) if params[:unassigned] == 'true'
        scope = scope.where('title LIKE ?', "%#{params[:q]}%") if params[:q].present?
        scope.order(created_at: :desc)
      end

      def serialize_request(request)
        {
          id: request.id,
          title: request.title,
          description: request.description,
          status: request.status,
          priority: request.priority,
          creator_id: request.creator_id,
          assignee: request.assignee ? { id: request.assignee.id, name: request.assignee.name } : nil,
          team_id: request.team_id,
          resolved_at: request.resolved_at,
          comments_count: request.comments.count,
          created_at: request.created_at,
          updated_at: request.updated_at
        }
      end

      def serialize_request_detail(request)
        {
          id: request.id,
          title: request.title,
          description: request.description,
          status: request.status,
          priority: request.priority,
          creator_id: request.creator_id,
          assignee: request.assignee ? { id: request.assignee.id, name: request.assignee.name, email: request.assignee.email } : nil,
          team_id: request.team_id,
          resolved_at: request.resolved_at,
          comments: request.comments.includes(:team_member).order(created_at: :asc).map { |c|
            {
              id: c.id,
              body: c.body,
              team_member: { id: c.team_member.id, name: c.team_member.name },
              created_at: c.created_at
            }
          },
          created_at: request.created_at,
          updated_at: request.updated_at
        }
      end
    end
  end
end
