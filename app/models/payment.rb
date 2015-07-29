class Payment
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response

  def create(params, session, auth_token)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+auth_token }, body: params }
    @response = self.class.post("/payments", options)
  end
end