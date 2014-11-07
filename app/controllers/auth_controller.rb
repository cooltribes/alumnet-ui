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
      session[:current_user] = Marshal.dump(user_session.user)
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
    registration.register(signup_params)
    if registration.valid?
      session[:current_user] = Marshal.dump(registration.user)
      redirect_to root_path
    else
      @first_name, @last_name, @email = signup_params[:first_name], signup_params[:last_name], signup_params[:email]
      @errors = registration.errors
      render :home
    end
  end

  def sign_out
    session[:current_user] = nil
    redirect_to root_path
  end

  private
    def signin_params
      params.require(:user).permit(:email, :password)
    end

    def signup_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
    end
end
