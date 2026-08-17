Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ], controllers: { sessions: "users/sessions" }

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  # Public, tenant-scoped, no login required — the QR menu ("Carta QR").
  get "menu" => "public_menu#show", as: :public_menu

  # Restaurant sign-up flow (creates the tenant + first owner user). Only meant
  # to be visited without a subdomain (the marketing/root host).
  resource :signup, only: [ :new, :create ], controller: "signups"

  resources :dining_tables do
    member do
      get :qr
      post :open
    end
  end

  resources :menu_categories
  resources :menu_items

  resources :discounts

  resources :users, except: [ :show ]

  resource :restaurant_settings, only: [ :edit, :update ]

  # Ventas por mostrador (counter sales / POS)
  get "pos" => "pos#index", as: :pos
  post "pos" => "pos#create"

  # Pantalla de cocina (comandas pendientes)
  get "kitchen" => "kitchen#index", as: :kitchen
  post "kitchen/order_items/:id/serve" => "kitchen#serve", as: :serve_kitchen_order_item

  resources :orders, only: [ :show, :update ] do
    member do
      get :comanda
      get :bill
      post :send_to_kitchen
      post :pay
      post :cancel
    end
    resources :order_items, only: [ :create, :update, :destroy ]
  end

  resources :cash_sessions, only: [ :new, :create, :show, :index ] do
    member { patch :close }
    resources :cash_movements, only: [ :create, :destroy ]
  end
end
