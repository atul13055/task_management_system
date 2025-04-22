require 'sidekiq/web'
Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
 mount Sidekiq::Web => '/sidekiq' if Rails.env.development? || Rails.env.production?


get 'test_mailer', to: 'test_mailer#send_test_email'

  namespace :api do
    namespace :v1 do
      # Auth routes
      post   'signup', to: 'auth#signup'
      post   'login',  to: 'auth#login'

      # User profile
      get 'users/profile', to: 'users#profile'
      #team
      resources :teams do
        member do
          post 'invite'
          get  'members'
          get  'inviteable_users'
        end
        resources :tasks, only: [:index, :create]
      end
      #tasks
      resources :tasks, only: [:show, :update, :destroy] do
        member do
          patch 'assign'
        end
      end
    end
  end
end
