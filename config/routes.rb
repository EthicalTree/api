Rails.application.routes.draw do

  # Sessions
  post :login, to: 'user_token#create'

  # Signup
  post :signup, to: 'users#create'
  post :confirm_email, to: 'users#confirm_email'

  get :location, to: 'users#get_location'
  resources :users, only: %i{show}

  # API
  namespace :v1 do
    resources :listings do
      resources :images
      resources :ethicalities
      resources :locations
      resources :operating_hours
    end
  end

  # S3
  namespace :s3 do
    get :sign, to: 's3#sign'
  end

end
