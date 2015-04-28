class LinkedinController < ApplicationController
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def auth
    init_client
    callback_url = if params[:registration]
      "http://#{request.host_with_port}/linkedin/callback?registration=1"
    else
      "http://#{request.host_with_port}/linkedin/callback"
    end
    request_token = @client.request_token(:oauth_callback => callback_url)
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to @client.request_token.authorize_url
  end

  def callback
    init_client
    if session[:atoken].nil?
      pin = params[:oauth_verifier]
      atoken, asecret =  @client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      session[:atoken] = atoken
      session[:asecret] = asecret
    else
      @client.authorize_from_access(session[:atoken], session[:asecret])
    end
    if params[:registration]
      init_registration
    else
      init_session
    end
  end

  def registration
    init_client
    @client.authorize_from_access(session[:atoken], session[:asecret])
    @path = linkedin_sign_up_path
    @email = @linkedin.auth_params[:email]
    render 'auth/registration'
  end

  def sign_up
    registration = UserRegistration.new
    registration.register(user_params)
    if registration.valid?
      init_client
      @client.authorize_from_access(session[:atoken], session[:asecret])
      session[:auth_token] = registration.user.auth_token
      init_registration
    else
      @email = user_params[:email]
      @errors_registration = registration.errors
      render 'auth/registration'
    end
  end

  private
    def init_client
      @linkedin = AlumnetLinkedin.new
      @client = @linkedin.client
    end

    def init_session
      user_session = UserSession.new
      user_session.oauth(@linkedin.auth_params)
      if user_session.valid?
        session[:atoken] = nil
        session[:asecret] = nil
        session[:auth_token] = user_session.user.auth_token
        redirect_to root_path
      else
        redirect_to linkedin_registration_path
      end
    end

    def init_registration
      session[:linkedin_profile] = @linkedin.profile
      redirect_to "http://#{request.host_with_port}/#registration"
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end