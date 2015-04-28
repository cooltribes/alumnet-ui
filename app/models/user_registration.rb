class UserRegistration
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  validate :success_of_last_response

  attr_accessor :last_response

  def register(user_params)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" },
      body: { user: user_params } }
    @last_response = self.class.post("/register", options)
  end

  def from_omniauth(auth)
   # auth.uid
    # where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
    #   user.provider = auth.provider
    #   user.uid = auth.uid
    #   user.name = auth.info.name
    #   user.oauth_token = auth.credentials.token
    #   user.oauth_expires_at = Time.at(auth.credentials.expires_at)
    #   user.save!
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" },
    body: { user: auth } }
    @last_response = self.class.post("/registerFacebook", options)
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