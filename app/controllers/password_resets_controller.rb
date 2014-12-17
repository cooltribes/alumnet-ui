class PasswordResetsController < ApplicationController
  layout "public"
  skip_before_action :setup_gon
  skip_before_action :authenticate!

  def new
  end

  def create
    password_reset = PasswordReset.new
    password_reset.send_email(params[:email])
    if password_reset.valid?
      redirect_to home_path, notice: password_reset.confirmation_message
    else
      @errors = password_reset.errors
      @email = params[:email]
      render :new
    end
  end

  def edit
    @token = params[:id]
  end

  def update
    token, password, password_confirmation = params[:id], params[:password], params[:password_confirmation]
    password_reset = PasswordReset.new
    password_reset.update_password(token, password, password_confirmation)
    if password_reset.valid?
      redirect_to home_path, notice: password_reset.confirmation_message
    else
      @errors = password_reset.errors
      @token = token
      render :edit
    end
  end
end
