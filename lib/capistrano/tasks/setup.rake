namespace :setup do

  desc "Upload database.yml file."
  task :upload_initial_files do
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(File.read("config/application.yml")), "#{shared_path}/config/application.yml"
      upload! StringIO.new(File.read("config/.env")), "#{shared_path}/config/.env"
    end
  end
end