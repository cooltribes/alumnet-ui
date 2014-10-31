class AuthController < ApplicationController
  def sign_in
    user_session = UserSession.new
    user_session.auth(user_params)
    if user_session.valid?
      session[:current_user] = user_session.user
    else
      render json: user_session.errors, status: :conflict
    end
  end

  def sign_out
    session[:current_user] = nil
    redirect root_path
  end

  private
    def user_params
      params.require(:user).permit(:email, :password)
    end
end
