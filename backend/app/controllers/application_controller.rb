class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error

  private

  def render_not_found(exception)
    render json: {
      error: "Not found",
      details: [exception.message]
    }, status: :not_found
  end

  def render_validation_error(exception)
    render json: {
      error: "Validation failed",
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def render_error(message, details = [], status: :unprocessable_entity)
    render json: {
      error: message,
      details: Array(details)
    }, status: status
  end
end
