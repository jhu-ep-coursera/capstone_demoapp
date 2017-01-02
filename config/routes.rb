Rails.application.routes.draw do

  get 'authn/whoami'
  get 'authn/checkme'

  mount_devise_token_auth_for 'User', at: 'auth'

  scope :api, defaults: {format: :json}  do 
    resources :foos, except: [:new, :edit]
    resources :bars, except: [:new, :edit]
    resources :images, except: [:new, :edit]
    resources :things, except: [:new, :edit]
  end      

  get "/client-assets/:name.:format", :to => redirect("/client/client-assets/%{name}.%{format}")
#  get "/", :to => redirect("/client/index.html")

  get '/ui'  => 'ui#index'
  get '/ui#' => 'ui#index'
  root "ui#index"
end
