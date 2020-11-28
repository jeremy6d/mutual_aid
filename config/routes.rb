Rails.application.routes.draw do
  devise_for :volunteers
  resources :deliveries do
    collection do
      get "mine" => "deliveries#mine", as: :my
    end
  end
  resources :packing_slips, except: [:edit, :update, :destroy] do
    get 'print', on: :member
  end
  resources :aid_requests do
    member { patch 'dismiss' }
    resources :fulfillments   do
      member { patch 'cancel' }
    end
  end
  resources :fulfillments
  get "/r/:id" => "aid_requests#show", as: :shortlink
  get "/volunteers/unapproved" => "unapproved_volunteers#index", as: :unapproved_volunteers
  post "/volunteers/approve" => "unapproved_volunteers#update", as: :approve_volunteers
  get "/special-requests" => "special_requests#index", as: :special_requests
  patch "/deliveries/:id/update" => "delivery_fulfillments#update", as: :update_delivery
  get '/overview' => 'static#overview', as: :overview
  root to: 'static#index'
end
