Rails.application.routes.draw do
  get '/login', to: 'auth#login', as: :login
  post '/sign_in', to: 'auth#sign_in', as: :sign_in
  get '/sign_out', to: 'auth#sign_out', as: :sign_out

  root 'welcome#index'
end
