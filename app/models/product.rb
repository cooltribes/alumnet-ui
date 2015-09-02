class Product
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  attr_accessor :response

  def get(sku, auth_token)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1", "Authorization" => 'Token token='+auth_token }, body: { sku: sku } }
    @response = self.class.get("/products/find_by_sku", options)
  end
end