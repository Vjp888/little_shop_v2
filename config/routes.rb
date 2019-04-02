Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :admin do
    get '/dashboard', to: "orders#index"
  end

  get '/dashboard', to: "merchant/items#index"
  get '/profile', to: "users#show"
  get '/cart', to: "cart#show"
end