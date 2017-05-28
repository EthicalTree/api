Rails.application.routes.draw do
  post 'user_token' => 'user_token#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  # Sessions
  post :login, to: 'sessions#create'
  get :logout, to: 'sessions#destroy'

  # Signup
  post :signup, to: 'users#create'
  post :confirm_email, to: 'users#confirm_email'

  # API
  resources :listings do
    resources :images
    resources :ethicalities
    resources :locations do
      resources :operating_hours
    end
  end

  get '*home', to: 'home#index'

end
