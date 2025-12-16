Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # UMD Customization
  root "home#index"
  get "new" => "home#new", as: :start_new_application
  get "reset" => "home#reset", as: :reset
  get "sign_out" => "home#sign_out", as: :sign_out

  # this is handled by rack case, but this just allows us to have a URL helper
  get "logout" => "home#sign_out", as: :logout

  resources :users
  get "disable_admin" => "users#disable_admin", as: :disable_admin

  resources :prospects
  get "prospects/:id/resume" => "prospects#resume", as: :prospect_resume
  get "prospects/:id/thank_you" => "prospects#thank_you", as: :thank_you
  post "prospects/deactivate" => "prospects#deactivate", as: :deactivate

  resources :resumes

  get "configuration" => "configuration#show", as: :configuration
  post "configuration" => "configuration#update", as: :update_configuration

  match "/delayed_jobs" => DelayedJobWeb, anchor: false, via: %i[get post]
  # End UMD Customization
end
