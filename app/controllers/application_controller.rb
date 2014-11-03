class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate!
  before_action :setup_gon


  protected

  def current_user
    #DILEMA
    #this is bad idea. The objects dont should store in a session. Profinda way.
    #todo: store only the token the user info is get from api.
    Marshal.load(session[:current_user]) if session[:current_user].present?
  end
  helper_method :current_user

  def setup_gon
    gon.api_endpoint = Settings.api_endpoint
    gon.current_user = current_user if signed_in?
  end

  def signed_in?
    current_user.present?
  end

  def authenticate!
    redirect_to home_path, notice: "You must login in" if current_user.nil?
  end
end
