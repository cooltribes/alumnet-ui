include ActionView::Helpers::NumberHelper
class DonationsController < ApplicationController
  layout "public"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def show
    donation = Donation.new
    @products = donation.products()
    # public_profile = PublicProfile.new
    # @user = public_profile.user(params[:slug])

    # unless public_profile.valid?
    #   render 'errors/e404'
    # end
  end

  def donate
    
  end


end
