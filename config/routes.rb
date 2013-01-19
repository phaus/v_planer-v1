VPlaner::Application.routes.draw do
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

  resources :services

  resources :expenses

  resource :export, :controller => 'export'

  resources :rentals do
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

    resources :rental_periods
    resources :rental_periods, :as => :items
    resources :device_items, :controller => :rental_periods
    resources :service_items
    resource :invoice
  end

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

  resources :rental_periods do
    collection do
      get :calendar
    end
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
    resources :rental_periods
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

  resource :admin, :controller => 'admin'

  namespace :admin do
    resources :companies
    resources :company_sections
    resources :users
  end

  root :to => 'account#show'

end
