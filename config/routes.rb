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
        patch 'mutate', constraints: { format: 'json' }
      end
    end
  end
  get "/r/:id" => "aid_requests#show", as: :shortlink
  get "/volunteers/unapproved" => "unapproved_volunteers#index", as: :unapproved_volunteers
  post "/volunteers/approve" => "unapproved_volunteers#update", as: :approve_volunteers
  root to: 'static#index'
end
