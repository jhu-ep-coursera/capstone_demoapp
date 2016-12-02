Rails.application.routes.draw do
  scope :api, defaults: {format: :json}  do 
    resources :foos, except: [:new, :edit]
  end      
end
