class UserMailer < ApplicationMailer
  def send_otp(user, otp)
    @otp = otp
     @user = user
    mail(to: @user.email, subject: 'Your OTP for account activation')
  end

  def send_forgot_password_otp(user, otp)
    @user = user
    @otp = otp
    mail(to: user.email, subject: 'OTP for Password Reset')
  end
end
