Rails.application.routes.draw do
  devise_for :volunteers
  resources :aid_requests do
    resources :fulfillments
  end
  root to: 'aid_requests#index'
 end
