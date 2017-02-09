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
  post 'resend_email_confirm/:token', to: 'users#resend_email_confirm', as: :resend_email_confirm
  get 'confirm_email/:token', to: 'users#confirm_email', as: :confirm_email

end
