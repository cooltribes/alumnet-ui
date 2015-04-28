class UserSession
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  validate :success_of_last_response

  attr_accessor :last_response

  def auth(params)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: params }
    @last_response = self.class.post("/sign_in", options)
  end

  def oauth(params)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: params }
    @last_response = self.class.post("/oauth_sign_in", options)
  end

  def user
    @user ||= User.new(@last_response.parsed_response)
  end

  def success_of_last_response
    errors.add(:base, last_response["error"]) unless last_response.success?
  end
end