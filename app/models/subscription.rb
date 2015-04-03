class Subscription
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response, :response_user

  def create(user_params, session, user_data, user_id)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_params }
    #options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token=1tzevg9jxnyegyVjVBVfaL8vSCFEaYfn-ToWXKi1DM1y58L_nWFbXs-6F9b8vGgPa2crzzeVKeFMvucMhMMxUg' }, body: user_params }
    @response = self.class.post("/users/"+user_id+"/subscriptions", options)

    options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_data }
    #options_user = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token=1tzevg9jxnyegyVjVBVfaL8vSCFEaYfn-ToWXKi1DM1y58L_nWFbXs-6F9b8vGgPa2crzzeVKeFMvucMhMMxUg' }, body: user_data }
    @response_user = self.class.put("/users/"+user_id, options_user)
    #user = User.find(user_params[:user_id])
    #user.member = 1
    #user.save
  end
end