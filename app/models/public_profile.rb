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
    return @last_response.success? ? create_user : nil
  end

  def create_user
    @skills_collection = @last_response.parsed_response.delete("skills")
    @languages_collection = @last_response.parsed_response.delete("languages")
    @experiences_collection = @last_response.parsed_response.delete("experiences")
    @user = OpenStruct.new(@last_response.parsed_response)
    @user.skills = convert_collection(@skills_collection)
    @user.languages = convert_collection(@languages_collection)
    set_experiences(@user, @experiences_collection)
    @user
  end

  def convert_collection(collection)
    collection.inject([]) { |array, hash| array << OpenStruct.new(hash) }
  end

  def set_experiences(user, experiences_collection)
    user.aiesec_experiences  = []
    user.alumni_experiences  = []
    user.academic_experiences  = []
    user.profesional_experiences  = []
    experiences_collection.each do |exp|
      user.aiesec_experiences << OpenStruct.new(exp) if exp['exp_type'] == 0
      user.alumni_experiences << OpenStruct.new(exp) if exp['exp_type'] == 1
      user.academic_experiences << OpenStruct.new(exp) if exp['exp_type'] == 2
      user.profesional_experiences << OpenStruct.new(exp) if exp['exp_type'] == 3
    end
  end

  def success_of_last_response
    errors.add(:base, last_response["error"]) unless last_response.success?
  end
end