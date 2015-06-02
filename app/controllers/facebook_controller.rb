class FacebookController < ApplicationController
  skip_before_action :setup_gon
  skip_before_action :authenticate!
  before_action :check_provider, only: [:registration, :sign_up, :sign_in]

  def callback
    if request.env['omniauth.auth'].any?
      facebook = request.env['omniauth.auth'].extra.raw_info
      params = { email: facebook.email, uid: facebook.id, provider: "facebook",
        first_name: facebook.first_name, last_name: facebook.last_name, gender: facebook.gender[0].capitalize,
        avatar_url: request.env['omniauth.auth'].info.image }
      session[:facebook_profile] = params
      init_session(params)
    else
      redirect_to home_path
    end
  end

  def registration
    @sign_up_email = session[:facebook_profile]["email"]
    render 'auth/registration'
  end

  def sign_up
    registration = UserRegistration.new
    registration.oauth_register(user_params, session[:facebook_profile], cookies[:invitation_token])
    if registration.valid?
      session[:auth_token] = registration.user.auth_token
      redirect_to "http://#{request.host_with_port}/#registration"
    else
      @sign_up_email = user_params[:email]
      @errors_registration = registration.errors
      render 'auth/registration'
    end
  end

  def sign_in
    user_session = UserSession.new
    user_session.auth(signin_params.merge(session[:facebook_profile].except(:email)))
    if user_session.valid?
      session[:auth_token] = user_session.user.auth_token
      redirect_to root_path
    else
      @email = signin_params[:email]
      @sign_up_email = session[:facebook_profile]["email"]
      @errors_login = user_session.errors
      render 'auth/registration'
    end
  end

  private

    def check_provider
      if session[:facebook_profile].present?
        @provider = "facebook"
      else
        redirect_to home_path
      end
    end

    def init_session(params)
      user_session = UserSession.new
      user_session.oauth(params)
      if user_session.valid?
        session[:auth_token] = user_session.user.auth_token
        redirect_to root_path
      else
        redirect_to facebook_registration_path
      end
    end

    def signin_params
      params.require(:user).permit(:email, :password)
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end