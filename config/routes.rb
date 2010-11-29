Rails.application.routes.draw do
  namespace :mezu do
    root :to => "messages#index"
    resources :messages do
      member do
        get :remove
      end
    end
  end
end
