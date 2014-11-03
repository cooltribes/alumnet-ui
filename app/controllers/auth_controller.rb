class AuthController < ApplicationController
  layout "public"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def login
  end

  def sign_in
    user_session = UserSession.new
    user_session.auth(user_params)
    if user_session.valid?
      session[:current_user] = Marshal.dump(user_session.user)
      redirect_to root_path
    else
      # render json: user_session.errors, status: :conflict
      @email = user_params[:email]
      @errors = user_session.errors
      render :login
    end
  end

  def sign_up
  end

  def sign_out
    session[:current_user] = nil
    redirect_to root_path
  end

  private
    def user_params
      params.require(:user).permit(:email, :password)
    end
end
