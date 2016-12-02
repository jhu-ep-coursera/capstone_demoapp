Rails.application.routes.draw do
  resources :bars, except: [:new, :edit]
  scope :api, defaults: {format: :json}  do 
    resources :foos, except: [:new, :edit]
  end      
end
