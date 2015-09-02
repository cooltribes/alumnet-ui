class LinkedinController < ApplicationController
  skip_before_action :setup_gon
  skip_before_action :authenticate!
  before_action :check_provider, only: [:registration, :sign_up, :sign_in]

  def auth
    init_client
    flag = params[:registration] ? "?registration=1" : ""
    request_token = @client.request_token(:oauth_callback => "http://#{request.host_with_port}/auth/linkedin/callback#{flag}")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to @client.request_token.authorize_url
  end

  def callback
    init_client
    if params[:oauth_problem].present?
      check_problems(params[:oauth_problem])
    else
      if session[:atoken].nil?
        pin = params[:oauth_verifier]
        atoken, asecret =  @client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
        session[:atoken] = atoken
        session[:asecret] = asecret
      else
        @client.authorize_from_access(session[:atoken], session[:asecret])
      end
      if params[:registration]
        redirect_to root_path
      else
        init_session
      end
    end
  end

  def registration
    @sign_up_email = @linkedin.auth_params[:email]
    render 'auth/registration'
  end

  def sign_up
    init_client
    registration = UserRegistration.new
    registration.oauth_register(user_params, @linkedin.auth_params, cookies[:invitation_token])
    if registration.valid?
      session[:auth_token] = registration.user.auth_token
      redirect_to root_path
    else
      @sign_up_email = user_params[:email]
      @errors_registration = registration.errors
      render 'auth/registration'
    end
  end

  def sign_in
    init_client
    user_session = UserSession.new
    user_session.auth(signin_params.merge(@linkedin.auth_params.except(:email)))
    if user_session.valid?
      session[:auth_token] = user_session.user.auth_token
      redirect_to root_path
    else
      @email = signin_params[:email]
      @sign_up_email = @linkedin.auth_params[:email]
      @errors_login = user_session.errors
      render 'auth/registration'
    end
  end

  private

    def check_provider
      init_client
      @provider = "linkedin"
    end

    def init_client
      @linkedin = AlumnetLinkedin.new
      @client = @linkedin.client
      if session[:atoken].present? && session[:asecret].present?
        @client.authorize_from_access(session[:atoken], session[:asecret])
      end
    end

    def init_session
      user_session = UserSession.new
      user_session.oauth(@linkedin.auth_params)
      if user_session.valid?
        session[:auth_token] = user_session.user.auth_token
        redirect_to root_path
      else
        redirect_to linkedin_registration_path
      end
    end

    def check_problems(params)
      if params == "user_refused"
        redirect_to home_path
      end
    end

    def signin_params
      params.require(:user).permit(:email, :password)
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end