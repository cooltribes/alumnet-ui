OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '1600226426901129', '834ecb7f66c9384b4bc95d0ccac0ae46',
    image_size: 'large', secure_image_url: true
end