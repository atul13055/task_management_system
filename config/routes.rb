Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  namespace :api do
    namespace :v1 do
      # Auth routes
      namespace :auth do
        post 'signup', to: 'auth#signup'
        post 'login', to: 'auth#login'
        delete 'logout', to: 'auth#logout' # Add logout if you plan to have it
      end
      get 'users/profile', to: 'users#profile' # Corrected 'user' to 'users'
    end
  end
end
