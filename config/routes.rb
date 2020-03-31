Rails.application.routes.draw do
  devise_for :volunteers
  resources :aid_requests
  root to: 'aid_requests#index'
 end
