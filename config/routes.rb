Rails.application.routes.draw do
  get '/home', to: 'auth#home', as: :home
  post '/sign_in', to: 'auth#sign_in', as: :sign_in
  post '/sign_up', to: 'auth#sign_up', as: :sign_up
  get '/sign_out', to: 'auth#sign_out', as: :sign_out
  resources :password_resets, except: [:index, :show, :destroy]

  #static pages
  get '/about', to: 'pages#about', as: :about
  get '/contact', to: 'pages#contact', as: :contact
  get '/donate', to: 'pages#donate', as: :donate
  get '/join', to: 'pages#join', as: :join
  get '/privacy', to: 'pages#privacy', as: :privacy
  get '/terms', to: 'pages#terms', as: :terms

  root 'welcome#index'
  # get '*unmatched_route', to: 'application#raise_not_found!'
end
