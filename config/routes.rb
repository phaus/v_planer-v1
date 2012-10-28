# ActionController::AbstractRequest.relative_url_root = '/v_planer'

ActionController::Routing::Routes.draw do |map|
  map.resources :default_texts

  map.resources :invoice_items

  map.resources :invoices, :collection => {:open => :get}

  map.resources :distributors

  map.resource :account, :controller => 'account'

  map.resource :company

  map.resource :bank_account

  map.resources :users

  map.resource :user_session

  map.connect '/products/:t/search/:q',
      :controller => 'products',
      :action     => 'search'

  map.connect '/products/:t/search',
      :controller => 'products',
      :action     => 'search'

  map.resources :products,
      :collection => {
          :rentable => :get,
          :sellable => :get,
          :service  => :get,
          :device   => :get,
          :expense  => :get,
          :search   => :get }

  map.resources :services

  map.resources :expenses

  map.resource :export, :controller => 'export'

  map.resources :rentals,
      :collection => {:open => :get},
      :member     => {:offer => :get, :packing_note => :get, :remarks => [:put, :get], :offer_confirmation => :get} do |rentals|
    rentals.resources :rental_periods
    rentals.resources :rental_periods, :as => :items
    rentals.resources :device_items, :controller => :rental_periods
    rentals.resources :service_items
    rentals.resource :invoice
  end

  map.resources :sellings,
      :collection => {:open => :get},
      :member     => {:offer => :get, :packing_note => :get, :remarks => [:put, :get], :offer_confirmation => :get} do |sellings|
    sellings.resources :selling_items, :as => :items
    sellings.resources :device_items, :controller => :selling_items
    sellings.resources :service_items
    sellings.resource :invoice
  end

  map.resources :rental_periods,
      :collection => {:calendar => :get}

  map.resources :devices, :member => {:availability => :get} do |devices|
    devices.resources :categories
  end

  map.resources :clients,
      :collection => { :search => :get } do |clients|
    clients.resources :rental_periods
  end

  map.resources :categories do |categories|
    categories.connect '/products/:t/search/:q',
        :controller => 'products',
        :action     => 'search'

    categories.resources :products,
        :collection => {
            :rentable => :get,
            :sellable => :get,
            :service  => :get,
            :device   => :get,
            :expense  => :get,
            :search   => :get }
  end

  map.resource :admin, :controller => 'admin'

  map.namespace :admin do  |admin|
    admin.resources :companies
    admin.resources :company_sections
    admin.resources :users
  end

  map.root :controller => 'account', :action => 'show'

end
