module ApplicationHelper

  def sign_up_path_for(provider)
    Rails.application.routes.url_helpers.send("#{provider}_sign_up_path")
  end

  def sign_in_path_for(provider)
    Rails.application.routes.url_helpers.send("#{provider}_sign_in_path")
  end
end
