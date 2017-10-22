Rails.application.routes.draw do

  # Sessions
  post :login, to: 'user_token#create'
  post :forgot_password, to: 'users#forgot_password'

  # Signup
  post :signup, to: 'users#create'
  post :confirm_email, to: 'users#confirm_email'

  get :location, to: 'users#get_location'
  resources :users, only: %i{show update}

  # API
  namespace :v1 do
    get :search, to: 'search#search'
    resources :ethicalities
    resources :listings do
      resources :images
      resources :listing_ethicalities
      resources :locations
      resources :operating_hours
    end

    namespace :admin do
      resources :users
    end
  end

  # S3
  namespace :s3 do
    get :sign, to: 's3#sign'
  end

  # Status
  get :status, to: 'status#index'

end
