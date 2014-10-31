Rails.application.routes.draw do
  get '/home', to: 'auth#home', as: :home
  post '/sign_in', to: 'auth#sign_in', as: :sign_in
  post '/sign_up', to: 'auth#sign_up', as: :sign_up
  get '/sign_out', to: 'auth#sign_out', as: :sign_out

  root 'welcome#index'
end
