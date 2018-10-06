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

    resources :ethicalities
    resources :plans
    resources :tags
    resources :seo_paths, only: %i{index}
    resources :directory_locations, path: :locations

    resources :collections do
      resources :images
    end

    resources :listings do
      resources :menus do
        resources :images
      end
      resources :images
      resources :listing_ethicalities, path: :ethicalities
      resources :listing_tags, path: :tags
      resources :locations
      resources :operating_hours
    end

    # Admin
    namespace :admin do
      resources :users
      resources :tags
      resources :listings
      resources :collections
      resources :locations
      resources :seo_paths
      resources :exports, only: %i{index}
      resources :imports, only: %i{create}
    end
  end

  # S3
  namespace :s3 do
    get :sign, to: 's3#sign'
    get :sign_collection, to: 's3#sign_collection'
  end

  # Status
  get :status, to: 'status#index'

  match "*path", to: "proxy#index", via: :all
end
