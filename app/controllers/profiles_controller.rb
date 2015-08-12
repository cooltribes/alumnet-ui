class ProfilesController < ApplicationController
  layout "public"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def show
    public_profile = PublicProfile.new
    @user = public_profile.user(params[:slug])

    byebug
    unless public_profile.valid?
      render 'errors/e404'
    end
  end


end
