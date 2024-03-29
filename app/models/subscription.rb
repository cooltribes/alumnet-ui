class Subscription
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response, :response_user

  def create(user_params, session, user_data, user_id, token)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+token }, body: user_params }
    @response = self.class.post("/users/"+user_id+"/subscriptions", options)
    
    options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+token }, body: user_data }
    @response_user = self.class.put("/users/"+user_id, options_user)
  end
end