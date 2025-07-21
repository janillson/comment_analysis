Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "analyze_user", to: "analysis#analyze_user"
      get "progress", to: "analysis#progress"

      resources :keywords, only: [:index, :create]
      delete "keywords/:word", to: "keywords#destroy", as: :destroy_keyword
    end
  end
end
