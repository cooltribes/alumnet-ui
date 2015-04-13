class Subscription
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response, :response_user

  def create(user_params, session, user_data, user_id)
    #options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_params }
    #produccion
    #options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token=32pR6X4NKALZpFukejiYghRvxsGE9CNWwmeozHUGY_zhhe4rEoHz45SXd_wAeSTTVDRcyHaHySSn15V1gQ8ZNg' }, body: user_params }
    #test
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token=1tzevg9jxnyegyVjVBVfaL8vSCFEaYfn-ToWXKi1DM1y58L_nWFbXs-6F9b8vGgPa2crzzeVKeFMvucMhMMxUg' }, body: user_params }
    @response = self.class.post("/users/"+user_id+"/subscriptions", options)

    #options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_data }
    #produccion
    #options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token=32pR6X4NKALZpFukejiYghRvxsGE9CNWwmeozHUGY_zhhe4rEoHz45SXd_wAeSTTVDRcyHaHySSn15V1gQ8ZNg' }, body: user_data }
    #test
    options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token=1tzevg9jxnyegyVjVBVfaL8vSCFEaYfn-ToWXKi1DM1y58L_nWFbXs-6F9b8vGgPa2crzzeVKeFMvucMhMMxUg' }, body: user_data }
    @response_user = self.class.put("/users/"+user_id, options_user)
  end
end