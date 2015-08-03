Rails.application.routes.draw do
  get '/home', to: 'auth#home', as: :home
  post '/sign_in', to: 'auth#sign_in', as: :sign_in
  post '/sign_up', to: 'auth#sign_up', as: :sign_up
  #get 'signout', to: 'auth#destroy', as: 'sign_out'
  get '/sign_out', to: 'auth#sign_out', as: :sign_out
  resources :password_resets, except: [:index, :show, :destroy]
  get '/paymentwall', to: 'paymentwall#callback', as: :paymentwall

  #static pages
  get '/about', to: 'pages#about', as: :about
  get '/contact', to: 'pages#contact', as: :contact
  get '/donate', to: 'pages#donate', as: :donate
  get '/joinAAI', to: 'pages#join', as: :join
  get '/privacy', to: 'pages#privacy', as: :privacy
  get '/terms', to: 'pages#terms', as: :terms

  root 'welcome#index'

  get '/auth/linkedin', to: 'linkedin#auth'
  get '/auth/linkedin/callback', to: 'linkedin#callback'
  get '/linkedin/registration', to: 'linkedin#registration', as: :linkedin_registration
  post '/linkedin/sign_in', to: 'linkedin#sign_in', as: :linkedin_sign_in
  post '/linkedin/sign_up', to: 'linkedin#sign_up', as: :linkedin_sign_up

  get '/auth/facebook/callback', to: 'facebook#callback'
  get '/facebook/registration', to: 'facebook#registration', as: :facebook_registration
  post '/facebook/sign_in', to: 'facebook#sign_in', as: :facebook_sign_in
  post '/facebook/sign_up', to: 'facebook#sign_up', as: :facebook_sign_up

  #public profiles
  get '/profiles', to: 'profiles#show'
  # get '/profiles', to: 'facebook#callback'


  #error pages
  get '/500', to: 'errors#e500', as: :e500
  get '/404', to: 'errors#e404', as: :e404
end
