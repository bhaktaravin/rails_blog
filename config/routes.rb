Rails.application.routes.draw do
  devise_for :users
  resources :posts
  
  # Newsletter subscriptions
  resources :newsletter_subscriptions, only: [:new, :create]
  get 'newsletters/unsubscribe/:token', to: 'newsletter_subscriptions#unsubscribe', as: :unsubscribe_newsletter
  post 'newsletters/resubscribe/:token', to: 'newsletter_subscriptions#resubscribe', as: :resubscribe_newsletter
  
  # API for n8n automation
  namespace :api do
    namespace :v1 do
      get 'newsletters/subscribers', to: 'newsletters#subscribers'
      post 'newsletters/webhook', to: 'newsletters#webhook'
      get 'newsletters/digest', to: 'newsletters#digest'
    end
  end
  
  # root "posts#index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
   root "posts#index"

   get "/health", to: proc { [200, {}, ["OK"]] }
   
   # SEO - Sitemap
   get '/sitemap.xml', to: redirect('/sitemaps/sitemap.xml.gz')

end
