class FacebookController < ApplicationController
  skip_before_action :setup_gon
  skip_before_action :authenticate!


  def callback
    facebook = request.env['omniauth.auth'].extra.raw_info
    params = { email: facebook.email, uid: facebook.id, provider: "facebook",
      first_name: facebook.first_name, last_name: facebook.last_name, gender: facebook.gender[0].capitalize,
      avatar_url: request.env['omniauth.auth'].info.image }
    session[:facebook_profile] = params
    init_session(params)
  end

  def registration
    @path = facebook_sign_up_path
    @email = session[:facebook_profile]["email"]
    render 'auth/registration'
  end

  def sign_up
    registration = UserRegistration.new
    registration.register(user_params)
    if registration.valid?
      session[:auth_token] = registration.user.auth_token
      redirect_to "http://#{request.host_with_port}/#registration"
    else
      @path = facebook_sign_up_path
      @email = user_params[:email]
      @errors_registration = registration.errors
      render 'auth/registration'
    end
  end

  private
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

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end