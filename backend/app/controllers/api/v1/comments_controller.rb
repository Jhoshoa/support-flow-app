module Api
  module V1
    class CommentsController < ApplicationController
      def create
        support_request = SupportRequest.find(params[:support_request_id])
        comment = support_request.comments.build(comment_params)
        comment.save!
        render json: serialize_comment(comment), status: :created
      end

      private

      def comment_params
        params.require(:comment).permit(:body, :team_member_id)
      end

      def serialize_comment(comment)
        {
          id: comment.id,
          body: comment.body,
          team_member_id: comment.team_member_id,
          support_request_id: comment.support_request_id,
          created_at: comment.created_at
        }
      end
    end
  end
end
