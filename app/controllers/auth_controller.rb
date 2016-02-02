class AuthController < ApplicationController
  layout "home"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def home
    cookies[:invitation_token] = params[:invitation_token] if params[:invitation_token].present?
  end

  def sign_in
    user_session = UserSession.new
    user_session.auth(signin_params)
    if user_session.valid?
      session[:auth_token] = user_session.user.auth_token
      if params[:remember] == "on"
        cookies.signed[:user_id] = { value: user_session.user.auth_token, expires: 2.weeks.from_now }
      end
      redirect_to root_path
    else
      @email = signin_params[:email]
      @errors_login = user_session.errors
      render :home
    end
  end

  def sign_up
    registration = UserRegistration.new
    registration.register(user_params, cookies[:invitation_token])
    if registration.valid?
      session[:auth_token] = registration.user.auth_token
      redirect_to root_path
    else
      @signup_email = user_params[:email]
      @errors_registration = registration.errors
      render :home
    end
  end

  def sign_out
    reset_session
    cookies.delete :user_id
    redirect_to home_path
  end

  private
    def signin_params
      params.require(:user).permit(:email, :password)
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
