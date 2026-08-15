Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ]

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  # Public, tenant-scoped, no login required — the QR menu ("Carta QR").
  get "menu" => "public_menu#show", as: :public_menu

  # Restaurant sign-up flow (creates the tenant + first owner user). Only meant
  # to be visited without a subdomain (the marketing/root host).
  resource :signup, only: [ :new, :create ], controller: "signups"

  resources :dining_tables do
    member { get :qr }
  end

  resources :menu_categories
  resources :menu_items

  resources :discounts

  resources :users, except: [ :show ]

  # Ventas por mostrador (counter sales / POS)
  get "pos" => "pos#index", as: :pos
  post "pos" => "pos#create"

  resources :orders, only: [ :show, :update ] do
    member do
      get :comanda
      post :send_to_kitchen
      post :pay
      post :cancel
    end
  end

  resources :cash_sessions, only: [ :new, :create, :show, :index ] do
    member { patch :close }
    resources :cash_movements, only: [ :create, :destroy ]
  end
end
