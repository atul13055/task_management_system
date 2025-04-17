class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_user

  private

  def authorize_request
    header = request.headers['Authorization']
    token = if header.present?
              header.split(' ').last
            else
              params[:token]
            end

    if token.present?
      begin
        decoded = JsonWebToken.decode(token)
        @current_user = User.find_by(id: decoded[:user_id]) if decoded
      rescue JWT::DecodeError => e
        render json: { error: 'Invalid token format' }, status: :unauthorized
      end
      render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
    else
      render json: { error: 'Token missing' }, status: :unauthorized
    end
  end
end
