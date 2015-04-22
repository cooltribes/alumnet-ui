class LinkedinController < ApplicationController

  def auth
    init_client
    request_token = @client.request_token(:oauth_callback => "http://#{request.host_with_port}/linkedin/callback")
    session[:rtoken] = request_token.token
    session[:rsecret] = request_token.secret
    redirect_to @client.request_token.authorize_url
  end

  def callback
    init_client
    if session[:atoken].nil?
      pin = params[:oauth_verifier]
      atoken, asecret =  @client.authorize_from_request(session[:rtoken], session[:rsecret], pin)
      session[:atoken] = atoken
      session[:asecret] = asecret
    else
      @client.authorize_from_access(session[:atoken], session[:asecret])
    end
    session[:atoken] = nil
    session[:asecret] = nil
    session[:linkedin_profile] = @linkedin.profile
    redirect_to "http://#{request.host_with_port}/#registration"
  end

  private
    def init_client
      @linkedin = AlumnetLinkedin.new
      @client = @linkedin.client
    end
end