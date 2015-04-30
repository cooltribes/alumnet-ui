class AuthController < ApplicationController
  layout "home"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def home
    session[:atoken] = nil
    session[:asecret] = nil
    session[:linkedin_profile] = nil
    session[:facebook_profile] = nil
  end

  def sign_in
    user_session = UserSession.new
    user_session.auth(signin_params)
    if user_session.valid?
      session[:auth_token] = user_session.user.auth_token
      redirect_to root_path
    else
      @email = signin_params[:email]
      @errors_login = user_session.errors
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
      @errors_registration = registration.errors
      render :home
    end
  end

  def sign_out
    session[:auth_token] = nil
    session[:linkedin_profile] = nil
    session[:facebook_profile] = nil
    session[:atoken] = nil
    session[:asecret] = nil
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
