class UserRegistration
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  validate :success_of_last_response

  attr_accessor :last_response

  def register(user_params, invitation_token = "")
    body_params = { user: user_params }
    body_params.merge!({ invitation_token: invitation_token}) if invitation_token.present?
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" },
      body: body_params }
    @last_response = self.class.post("/register", options)
  end

  def oauth_register(user_params, provider_params, invitation_token = "")
    body_params = { user: user_params.merge(oauth_providers_attributes: [provider_params]) }
    body_params.merge!({ invitation_token: invitation_token}) if invitation_token.present?
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" },
      body: body_params }
    @last_response = self.class.post("/oauth_register", options)
  end

  def user
    @user ||= User.new(@last_response.parsed_response)
  end

  def success_of_last_response
    unless last_response.success?
      last_response["errors"].each do |key, value|
        value.each do |msg|
          errors.add(key.to_sym, msg)
        end
      end
    end
  end
end