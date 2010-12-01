Rails.application.routes.draw do
  namespace :mezu do
    root :to => "messages#index"
    resources :messages do
      member do
        get :remove
        put :read, :as => :mark_as_read
      end
    end
  end
end
