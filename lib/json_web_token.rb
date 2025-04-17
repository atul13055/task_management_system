# lib/json_web_token.rb
class JsonWebToken
  SECRET_KEY = Rails.application.credentials.fetch(:secret_key_base) || ENV['DEVISE_JWT_SECRET_KEY']
  
  # Fetch expiration time from ENV or credentials (in minutes)
  EXPIRATION_TIME = Rails.application.credentials.fetch(:jwt_expiration_time, ENV['JWT_EXPIRATION_TIME'] || 160).to_i.minutes

  def self.encode(payload, exp = EXPIRATION_TIME)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS512' })[0]
    
    # Check if token has expired
    if decoded['exp'] < Time.now.to_i
      raise JWT::ExpiredSignature, 'Token has expired'
    end
    
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    nil  # Return nil if the token is invalid or expired
  rescue JWT::ExpiredSignature => e
    nil  # Return nil if the token is expired
  end
end
