include ActionView::Helpers::NumberHelper
class DonationsController < ApplicationController
  layout "public"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def show
    donation = Donation.new
    @products = donation.products()
    @campaign_details = donation.get_campaign_details()
    @goal_percentage = (@campaign_details['total_sold'].to_f * 100) / 300000
    @days_left = (DateTime.new(2016, 9, 30) - DateTime.now).to_i
    @donors = @campaign_details['donors']
    @countries = @campaign_details['countries']
  end

  def donate
    donation = Donation.new
    @product = donation.get_product(params[:id])
    @countries = donation.countries

    render 'errors/e404' unless @product.present?

    redirect_to "#donations/#{params[:id]}" if current_user.present?
  end

  def cities
    donation = Donation.new
    @cities = donation.cities(params[:country_id])
    render json: @cities
  end

  def committees
    donation = Donation.new
    @committees = donation.committees(params[:country_id])
    render json: @committees
  end

  def sign_in
    user_session = UserSession.new
    user_session.auth(signin_params)
    if user_session.valid?
      session[:auth_token] = user_session.user.auth_token
      if params[:remember] == "on"
        cookies.signed[:user_id] = { value: user_session.user.auth_token, expires: 2.weeks.from_now }
      end
      redirect_to "#donations/#{params[:product_id]}"
    else
      donation = Donation.new
      @email = signin_params[:email]
      @errors_login = user_session.errors
      @product = donation.get_product(params[:product_id])
      @countries = donation.countries

      render 'errors/e404' unless @product.present?
      render :donate
    end
  end

  def sign_up
    donation = Donation.new
    registration = UserRegistration.new
    password = SecureRandom.hex(10)
    attributes = { email: params[:user][:email], password: password, password_confirmation: password }
    registration.register(attributes)
    if registration.valid?
      donation.update_user(registration.user.id, params[:user], password, params[:experience])
      session[:auth_token] = registration.user.auth_token
      redirect_to "#donations/#{params[:product_id]}"
    else
      @signup_email = params[:user][:email]
      @registration_errors = registration.errors
      donation = Donation.new
      @product = donation.get_product(params[:product_id])
      @countries = donation.countries

      render 'errors/e404' unless @product.present?
      render :donate
    end
  end

  private
    def signin_params
      params.require(:user).permit(:email, :password)
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
