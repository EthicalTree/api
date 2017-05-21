Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'home#index'

  # Sessions
  get :login, to: 'sessions#new'
  post :login, to: 'sessions#create'
  get :logout, to: 'sessions#destroy'

  # Signup
  get :signup, to: 'users#new'
  post :signup, to: 'users#create'
  get :pending_confirmation, to: 'users#pending_confirmation'
  post :resend_email_confirm, to: 'users#resend_email_confirm'
  get 'confirm_email/:token', to: 'users#confirm_email', as: :confirm_email

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
