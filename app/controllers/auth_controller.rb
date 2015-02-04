class AuthController < ApplicationController
  layout "public"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def home
  end

  def sign_in
    user_session = UserSession.new
    user_session.auth(signin_params)
    if user_session.valid?
      session[:auth_token] = user_session.user.auth_token
      redirect_to root_path
    else
      @email = signin_params[:email]
      @errors = user_session.errors
      render :home
    end
  end

  def sign_up
    registration = UserRegistration.new
    registration.register(user_params)
    if registration.valid?
      session[:auth_token] = registration.user.auth_token
      redirect_to root_path
    else
      @signup_email = user_params[:email]
      @errors = registration.errors
      render :home
    end
  end

  def sign_out
    session[:auth_token] = nil
    redirect_to root_path
  end

  private
    def signin_params
      params.require(:user).permit(:email, :password)
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
