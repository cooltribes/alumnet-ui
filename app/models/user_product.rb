class UserProduct
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response, :response_user

  def create(user_params, session, user_id, token)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+token }, body: user_params }
    @response = self.class.post("/users/"+user_id+"/products", options)
  end

  def update_user(user_data, session, user_id, token)
    options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+token }, body: user_data }
    @response_user = self.class.put("/users/"+user_id, options_user)
  end

  def update_profile(profile_data, session, user_id, token)
    options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+token }, body: profile_data }
    @response_user = self.class.put("/users/profiles"+user_id, options_user)
  end
end