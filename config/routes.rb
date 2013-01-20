VPlaner::Application.routes.draw do
  mount VPlanerRental::Engine => '/rental', :as => 'rental'
  mount VPlanerAdmin::Engine  => '/admin',  :as => 'admin'

  resources :default_texts

  resources :invoice_items

  resources :invoices do
    collection do
      get :open
    end
  end

  resources :distributors

  resource :account, :controller => 'account'

  resource :company

  resource :bank_account

  resources :users

  resource :user_session

  get '/products/:t/search/:q' => 'products#search'
  get '/products/:t/search'    => 'products#search'

  resources :products do
    collection do
      get :rentable
      get :sellable
      get :service
      get :device
      get :expense
      get :search
    end
  end

  resources :commercial_processes do
    resources :process_items
  end

  resources :services

  resources :expenses

  resource :export, :controller => 'export'

  resources :sellings do
    collection do
      get :open
    end

    member do
      get :offer
      get :packing_note
      get :remarks
      put :remarks
      get :offer_confirmation
    end
    resources :selling_items, :as => :items
    resources :device_items, :controller => :selling_items
    resources :service_items
    resource :invoice
  end

  resources :devices do
    member  do
      get :availability
    end
    resources :categories
  end

  resources :clients do
    collection do
      get :search
    end
  end

  resources :categories do
    get '/products/:t/search/:q' => 'products#search'

    resources :products do
      collection do
        get :rentable
        get :sellable
        get :service
        get :device
        get :expense
        get :search
      end
    end
  end

  root :to => 'account#show'

end
