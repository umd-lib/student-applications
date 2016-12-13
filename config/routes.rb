Rails.application.routes.draw do
  root 'home#index'
  get "new" => "home#new", as: :start_new_application

  resources :prospects
  resources :resumes
  get 'prospects/:id/resume' => 'prospects#resume', as: :prospect_resume
  get 'prospects/:id/thank_you' => 'prospects#thank_you', as: :thank_you

  resources :enumerations
  get 'configuration' => 'configuration#show', as: :configuration
  post 'configuration' => 'configuration#update', as: :update_configuration
end
