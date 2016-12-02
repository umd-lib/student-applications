Rails.application.routes.draw do
  root 'home#index'

  resources :prospects
  resources :resumes
  get 'prospects/:id/resume' => 'prospects#resume', as: :prospect_resume
  get 'prospects/:id/thank_you' => 'prospects#thank_you', as: :thank_you
end
