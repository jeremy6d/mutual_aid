Rails.application.routes.draw do
  devise_for :volunteers
  resources :deliveries do
    collection do
      get "mine" => "deliveries#mine", as: :my
    end
  end
  resources :aid_requests do
    member { patch 'dismiss' }
    resources :fulfillments do
      member do
        patch 'delivered'
      end
    end
  end
  get "/r/:id" => "aid_requests#show", as: :shortlink
  get "/dashboard" => "aid_requests#index", as: :dashboard
  root to: 'static#index'
end
