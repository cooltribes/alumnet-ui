class PasswordReset
  include HTTParty
  include ActiveModel::Model

  base_uri 'http://localhost:4000'
  format :json

  validate :success_of_last_response

  attr_accessor :last_response

  def send_email(email)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" },
      body: { email: email } }
    @last_response = self.class.post("/password_resets", options)
  end

  def update_password(token, password, password_confirmation)
    options = { headers: { "Accept" => "application/vnd.alumnet+json;version=1" },
      body: { password: password, password_confirmation: password_confirmation } }
    @last_response = self.class.put("/password_resets/#{token}", options)
  end

  def confirmation_message
    if last_response.success?
      last_response.parsed_response["message"]
    end
  end

  def success_of_last_response
    unless last_response.success?
      last_response["errors"].each do |key, value|
        value.each do |msg|
          errors.add(key.to_sym, msg)
        end
      end
    end
  end
end