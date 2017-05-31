Rails.application.routes.draw do

  # Sessions
  post :login, to: 'user_token#create'

  # Signup
  post :signup, to: 'users#create'
  post :confirm_email, to: 'users#confirm_email'

  # API
  namespace :v1 do
    resources :listings do
      resources :images
      resources :ethicalities
      resources :locations do
        resources :operating_hours
      end
    end
  end

end
