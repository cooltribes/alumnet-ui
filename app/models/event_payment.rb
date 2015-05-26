class EventPayment
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response

  def create(event_params, session, event_id, auth_token)
    #options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+session[:auth_token] }, body: user_params }
    #produccion
    #options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token=32pR6X4NKALZpFukejiYghRvxsGE9CNWwmeozHUGY_zhhe4rEoHz45SXd_wAeSTTVDRcyHaHySSn15V1gQ8ZNg' }, body: user_params }
    #test
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+auth_token }, body: event_params }
    @response = self.class.post("/events/"+event_id+"/payments", options)
    #@response = { event_id: event_id }
  end
end