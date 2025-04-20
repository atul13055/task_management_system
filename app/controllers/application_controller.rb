class ApplicationController < ActionController::API
  include CanCan::ControllerAdditions

  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from CanCan::AccessDenied, with: :handle_authorization_error

  before_action :authorize_request

  attr_reader :current_user

  private

  def authorize_request
    header = request.headers['Authorization']
    token = header.present? ? header.split(' ').last : params[:token]

    if token.blank?
      render json: { error: 'Authorization token is missing' }, status: :unauthorized and return
    end

    begin
      decoded = JsonWebToken.decode(token)
      @current_user = User.find_by(id: decoded[:user_id])

      if @current_user.nil?
        render json: { error: 'Invalid token: user not found' }, status: :unauthorized and return
      end
    rescue JWT::ExpiredSignature
      render json: { error: 'Token has expired. Please log in again.' }, status: :unauthorized and return
    rescue JWT::DecodeError
      render json: { error: 'Invalid token format' }, status: :unauthorized and return
    end
  end

  def handle_not_found(exception)
    render json: {
      error: 'Resource not found',
      message: exception.message
    }, status: :not_found
  end

  def handle_authorization_error(exception)
    render json: {
      error: 'Access denied',
      message: exception.message
    }, status: :forbidden
  end
end
