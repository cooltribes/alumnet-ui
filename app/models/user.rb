class User
  include ActiveModel::Model
  attr_accessor :id, :email, :name, :auth_token
end