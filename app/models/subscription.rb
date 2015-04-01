class Subscription
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response, :response_user

  def create(user_params, session, user_data)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_params }
    @response = self.class.post("/users/1/subscriptions", options)

    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_data }
    @response_user = self.class.put("/users/1", options)
    #user = User.find(user_params[:user_id])
    #user.member = 1
    #user.save
  end

end