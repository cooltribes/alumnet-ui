class UserRegistration
  include HTTParty
  include ActiveModel::Model

  base_uri 'http://localhost:4000'
  format :json

  validate :success_of_last_response

  attr_accessor :last_response

  def register(params)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: params }
    @last_response = self.class.post("/register", options)
  end

  def user
    @user ||= User.new(@last_response.parsed_response)
  end

  def success_of_last_response
    errors.add(:base, last_response["errors"]) unless last_response.success?
  end
end