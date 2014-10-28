class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :setup_gon


  protected

  def setup_gon
    #for now
    gon.api_endpoint = Settings.api_endpoint
    gon.temp_token = Settings.temp_token
  end

  def current_user
    session[:current_user]
  end
  helper_method :current_user
end
