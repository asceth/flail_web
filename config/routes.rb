FlailWeb::Application.routes.draw do
  root :to => 'flail_exceptions#index'

  post '/swing' => 'flail_exceptions#create'

  resources :flail_exceptions
  resources :digests
  resources :web_hooks do
    collection do
      post :test
    end
  end
end
