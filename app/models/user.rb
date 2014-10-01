class User
  include ActiveModel::Model
  attr_accessor :id, :email, :api_token
end