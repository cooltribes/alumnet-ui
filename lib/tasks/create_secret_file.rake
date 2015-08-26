require 'rake'
namespace :app do

  desc "create a secret.yml for environment"
  task create_secret_file: :environment do
    require 'securerandom'
    file = Rails.root.join('config', 'secrets.yml')
    environment = Rails.env
    content = <<-EOS
test:
  secret_key_base: #{SecureRandom.hex(64)}
#{environment}:
  secret_key_base: #{SecureRandom.hex(64)}
    EOS
    File.open(file, 'w') do |f|
      f.write content
    end
  end
end