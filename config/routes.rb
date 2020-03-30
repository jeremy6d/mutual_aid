Rails.application.routes.draw do
  resources :aid_requests
  root to: 'aid_requests#index'
 end
