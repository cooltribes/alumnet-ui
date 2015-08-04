class PublicProfile
  include HTTParty
  include ActiveModel::Model

  base_uri Settings.api_endpoint
  format :json

  validate :success_of_last_response

  attr_accessor :last_response

  def user(slug)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" }, body: {} }
    @last_response = self.class.get("/public_profile/#{slug}", options)
    @last_response.success? ? OpenStruct.new(@last_response.parsed_response) : nil
  end

  def success_of_last_response
    errors.add(:base, last_response["error"]) unless last_response.success?
  end
end