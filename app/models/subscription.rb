class Subscription
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response

  def create(user_params, session)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_params }
    @response = self.class.post("/users/1/subscriptions", options)
  end

end