class Api::V1::AuthController < ApplicationController
  skip_before_action :authorize_request, only: [:signup, :login, :verify_otp, :resend_otp, :forgot_password, :reset_password]


  def signup
    user = User.new(user_params)
    if user.save
      otp = generate_otp
      user_otp = user.create_user_otp(otp: otp, expires_at: 10.minutes.from_now)
      UserMailer.send_otp(user, otp).deliver_now 
      render json: { messages: 'User Created Successfully, Please verify your email with the OTP sent.', data: UserSerializer.new(user) }, status: :created
    else
      render json: {errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def verify_otp
    user = User.find_by(email: params[:data][:email])
    return render json: { error: 'User not found' }, status: :not_found unless user

    return render json: { message: 'Email is already verified' }, status: :ok if user.is_verified?

    user_otp = user.user_otp
    if user_otp&.otp == params[:data][:otp]
      if user_otp.expires_at.future?
        user.update(is_verified: true, active: true)
        user_otp.destroy
        token = JsonWebToken.encode(user_id: user.id)
        render json: { message: 'Email verified successfully.', token: token }, status: :ok
      else
        render json: { error: 'OTP expired. Please request a new one.' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid OTP' }, status: :unprocessable_entity
    end
  end


  def resend_otp
    user = User.find_by(email: params[:data][:email])
    return render json: { error: 'User not found' }, status: :not_found unless user

    otp = generate_otp
    if user.user_otp
      user.user_otp.update(otp: otp, expires_at: 10.minutes.from_now)
    else
      user.create_user_otp(otp: otp, expires_at: 10.minutes.from_now)
    end

    UserMailer.send_otp(user, otp).deliver_now
    render json: { message: 'OTP resent to your email.' }, status: :ok
  end


  def login
    user = User.find_by(email: params[:data][:email])
    # debugger
    if user.nil? || !user.authenticate(params[:data][:password])
      if user
        # debugger
        user.increment!(:failed_attempts)
        if user.failed_attempts >= 3
          user.lock_account
          return render json: {
            error: 'Account locked due to 3 failed attempts. Try again after 10 minutes.'
          }, status: :forbidden
        end
      end
      return render json: { error: 'Invalid email or password' }, status: :unauthorized
    end

    if user.locked? && user.locked_at <= 10.minutes.ago
      user.reset_failed_attempts
    end

    if user.locked?
      return render json: {
        error: 'Account is locked. Please try again later.'
      }, status: :forbidden
    end

    unless user.is_verified?
      return render json: { error: 'Email not verified. Please verify using the OTP' }, status: :forbidden
    end

    user.reset_failed_attempts
    user.update_column(:last_logged_in, Time.current)
    token = JsonWebToken.encode(user_id: user.id)

    render json: {
      messages: 'Login Successful',
      data: UserSerializer.new(user),
      token: token
    }, status: :ok
  end

  def forgot_password
    user = User.find_by(email: params[:data][:email])
    return render json: { error: 'User not found' }, status: :not_found unless user

    otp = generate_otp
    user.user_forgot_password_otp&.destroy
    user.create_user_forgot_password_otp(otp: otp, expires_at: 10.minutes.from_now)
    UserMailer.send_forgot_password_otp(user, otp).deliver_now

    render json: { message: 'OTP sent yor email for password reset.' }, status: :ok
  end

  def reset_password
    user = User.find_by(email: params[:data][:email])
    return render json: { error: 'User not found' }, status: :not_found unless user

    otp_record = user.user_forgot_password_otp
    # byebug
    if otp_record&.otp == params[:data][:otp]
      if otp_record.expires_at.future?
        if params[:data][:password] != params[:data][:password_confirmation]
          return render json: { error: 'Passwords do not match' }, status: :unprocessable_entity
        end

        user.update(password: params[:data][:password], password_confirmation: params[:data][:password_confirmation])
        otp_record.destroy

        render json: { message: 'Password reset successful please login.' }, status: :ok
      else
        render json: { error: 'OTP expired' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid OTP' }, status: :unprocessable_entity
    end
  end



  private

  def user_params
    params.require(:data).permit(:name, :email, :username, :password, :password_confirmation)
  end

  def generate_otp
    rand(1000..9999).to_s  # Generate a 4-digit OTP
  end
end
