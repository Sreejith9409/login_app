Rails.application.routes.draw do
  root "sessions#new"
  resources :users

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'welcome', to: 'sessions#welcome'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  get 'authorized', to: 'sessions#page_requires_login'

  resources :api do
    collection do
      post :sign_up
      post :sign_in
      post :update_details
    end
  end
  post '/api/update_details/:id.:format' => 'api#update_details'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
