Rails.application.routes.draw do
  devise_for :volunteers
  resources :aid_requests do
    resources :fulfillments
  end
  get "/r/:id" => "aid_requests#show", as: :shortlink
  root to: 'aid_requests#index'
 end
