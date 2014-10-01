Rails.application.routes.draw do
  post '/sign_in', to: 'auth#sign_in', as: :sign_in
  post '/sign_out', to: 'auth#sign_out', as: :sign_out

  root 'welcome#index'
end
