class JsonWebToken
  class << self
    # Stronger encryption by default (HS512)
    ALGORITHM = 'HS512'.freeze

    # Fetch secret from credentials or ENV with fallback
    def secret_key
      @secret_key ||= Rails.application.credentials.dig(:jwt, :secret_key) || 
                      ENV['JWT_SECRET_KEY'] || 
                      Rails.application.secret_key_base
    end

    # Configurable expiration time (default: 24 hours)
    def expiration_time
      @expiration_time ||= 
        (Rails.application.credentials.dig(:jwt, :expiration_time) ||
        ENV['JWT_EXPIRATION_TIME'] || 
        24.hours)
    end

    # Generate token with custom payload
    def encode(payload, exp = expiration_time.from_now)
      payload = payload.dup
      payload[:exp] = exp.to_i
      JWT.encode(payload, secret_key, ALGORITHM)
    end

    # Decode and verify token
    def decode(token)
      decoded = JWT.decode(token, secret_key, true, { 
        algorithm: ALGORITHM,
        verify_expiration: true 
      })[0]
      
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::ExpiredSignature
      raise JWT::ExpiredSignature, 'Token has expired. Please login again.'
    rescue JWT::VerificationError
      raise JWT::VerificationError, 'Invalid token signature.'
    rescue JWT::DecodeError
      raise JWT::DecodeError, 'Invalid token format.'
    end

    # Helper method for controller concerns
    def current_user(token)
      payload = decode(token)
      User.find_by(id: payload[:user_id])
    rescue ActiveRecord::RecordNotFound
      raise 'User not found'
    end
  end
end
