class Donation
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  validate :success_of_last_response

  ### Relations
  #belongs_to :users, dependent: :destroy


  attr_accessor :last_response

  def products()
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: {} }
    @last_response = self.class.get("/donations/products", options)
    return @last_response
  end

  def get_product(id)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: {} }
    @last_response = self.class.get("/donations/products/#{id}", options)
    return @last_response.success? ? @last_response : nil
  end

  def countries()
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: {} }
    @last_response = self.class.get("/donations/countries", options)
    return @last_response
  end

  def cities(country_id)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: {} }
    @last_response = self.class.get("/donations/cities/#{country_id}", options)
    return @last_response
  end

  def committees(country_id)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: {} }
    @last_response = self.class.get("/donations/committees/#{country_id}", options)
    return @last_response
  end

  def update_user(user_id, user, password, experience, residence)
    params = { user_id: user_id, user: user, password: password, experience: experience, residence: residence }
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: params }
    @last_response = self.class.post("/donations/update_user", options)
    return @last_response
  end

  def get_campaign_details
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: {} }
    @last_response = self.class.get("/donations/details", options)
    return @last_response
  end

  def success_of_last_response
    errors.add(:base, last_response["error"]) unless last_response.success?
  end
end