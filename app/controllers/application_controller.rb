class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate!, except: :raise_not_found!
  before_action :setup_gon

  rescue_from ActionController::RoutingError, :with => :render_not_found

  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end

  protected

  def current_user
    session[:auth_token] if session[:auth_token].present?
  end
  helper_method :current_user

  def setup_gon
    gon.api_endpoint = Settings.api_endpoint
    gon.pusher_key = Settings.pusher_key
    gon.auth_token = current_user if signed_in?
    if session[:linkedin_profile].present?
      gon.linkedin_profile = session[:linkedin_profile]
    end
  end

  def signed_in?
    current_user.present?
  end

  def authenticate!
    redirect_to home_path unless signed_in?
  end

  def render_not_found
    render template: "errors/404"
  end
end
