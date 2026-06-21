
# Rails 6.1 brings back the feature that allows loading external route files from the router.

# TODO: See https://zenn.dev/n04h/articles/sidekiq-auth
#           Sidekiqの管理画面をアクセス制限する方法3選
require "sidekiq/web" # require the web UI


BonsaiErp::Application.routes.draw do
  resources :resources

  resources :curr_xchgs
  resources :invoices

  # namespace :api
  draw :api
  
  draw :app

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Routes specifically for the development environment
  if Rails.env.development?  
    mount Sidekiq::Web => "/sidekiq" # access it at http://localhost:3000/sidekiq
  end
  
end
