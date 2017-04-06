Rails.application.routes.draw do
#Retailer dont has routes for products , and retailer has routes for offered_products
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
       mount_devise_token_auth_for 'Distributor', at: 'distri_path'
       as :distributor do
          resources :products 
          resources :offered_products
        end
        mount_devise_token_auth_for 'Retailer', at: 'retai_path'
        as :retailer do
          resources :retailers do
            resources :orders
            resources :offered_products
          end
        end
  mount_devise_token_auth_for 'Distributor', at: 'distri_path'
  as :distributor do
    resources :distributors, only: [:index, :show] do
      get 'orders_by_arrival_date', to: 'orders#orders_by_arrival_date'
      get 'orders_by_exit_date', to: 'orders#orders_by_exit_date'
      resources :orders, except: [:create]
    end
  end
  mount_devise_token_auth_for 'Retailer', at: 'retai_path'
  as :retailer do
    resources :retailers, only: [:index, :show] do
      get 'orders_by_arrival_date', to: 'orders#orders_by_arrival_date'
      get 'orders_by_exit_date', to: 'orders#orders_by_exit_date'
      resources :orders
    end
  end

  resources :orders do
    resources :comments
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
