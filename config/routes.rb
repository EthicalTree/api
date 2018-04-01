Rails.application.routes.draw do

  # Sessions
  post :login, to: 'user_token#create'
  post :forgot_password, to: 'users#forgot_password'
  resources :sessions, only: %i{index}

  # Signup
  post :signup, to: 'users#create'
  post :confirm_email, to: 'users#confirm_email'
  resources :users, only: %i{show update}

  # API
  namespace :v1 do
    get :search, to: 'search#search'
    get :locations, to: 'search#locations'
    post :search_suggestions, to: 'search#suggestions'

    resources :ethicalities
    resources :curated_lists
    resources :plans
    resources :tags

    resources :listings do
      resources :menus do
        resources :images
      end
      resources :images
      resources :listing_ethicalities
      resources :listing_tags, path: :tags
      resources :locations
      resources :operating_hours
    end

    # Admin
    namespace :admin do
      resources :users
      resources :tags
      resources :listings
      resources :curated_lists
      resources :locations
    end
  end

  # S3
  namespace :s3 do
    get :sign, to: 's3#sign'
  end

  # Status
  get :status, to: 'status#index'

end
