Rails.application.routes.draw do
  resources :deliveries do
    collection do
      get "mine" => "deliveries#mine", as: :my
    end
  end
  devise_for :volunteers
  resources :aid_requests do
    resources :fulfillments do
      member do
        patch 'delivered'
      end
    end
    # do
    #   member do
    #     patch :mark_delivered => "fulfillments#mark_delivered"
    #   end
    # end
  end
  get "/r/:id" => "aid_requests#show", as: :shortlink
  root to: 'aid_requests#index'
end
