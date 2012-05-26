Tvtropes::Application.routes.draw do
  root :to => 'movies#index'

  resources :movies, :only => [:index, :show, :new, :create, :destroy]
  resources :tropes, :only => [:show]
end
