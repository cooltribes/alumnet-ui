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
      # session[:current_user] = Marshal.dump(user_session.user)
      session[:user_id] = user_session.user.id
      session[:api_token] = user_session.user.api_token
      redirect_to root_path
    else
      # render json: user_session.errors, status: :conflict
      @email = signin_params[:email]
      @errors = user_session.errors
      render :home
    end
  end

  def sign_up
    registration = UserRegistration.new
    registration.register(user_params, profile_params)
    if registration.valid?
      # session[:current_user] = Marshal.dump(registration.user)
      session[:user_id] = user_session.user.id
      session[:api_token] = user_session.user.api_token
      redirect_to root_path
    else
      @first_name, @last_name, @signup_email = profile_params[:first_name], profile_params[:last_name], user_params[:email]
      @errors = registration.errors
      render :home
    end
  end

  def sign_out
    session[:user_id] = nil
    session[:api_token] = nil
    redirect_to root_path
  end

  private
    def signin_params
      params.require(:user).permit(:email, :password)
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def profile_params
      params.require(:profile).permit(:first_name, :last_name)
    end

end
