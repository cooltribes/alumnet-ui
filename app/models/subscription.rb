class Subscription
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response, :response_user

  def create(user_params, session, user_data)
    #options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_params }
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token=32pR6X4NKALZpFukejiYghRvxsGE9CNWwmeozHUGY_zhhe4rEoHz45SXd_wAeSTTVDRcyHaHySSn15V1gQ8ZNg' }, body: user_params }
    @response = self.class.post("/users/1/subscriptions", options)

    #options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_data }
    options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token=32pR6X4NKALZpFukejiYghRvxsGE9CNWwmeozHUGY_zhhe4rEoHz45SXd_wAeSTTVDRcyHaHySSn15V1gQ8ZNg' }, body: user_data }
    @response_user = self.class.put("/users/1", options_user)
    #user = User.find(user_params[:user_id])
    #user.member = 1
    #user.save
  end
end