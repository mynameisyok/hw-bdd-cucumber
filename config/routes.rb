Rottenpotatoes::Application.routes.draw do
  devise_for :moviegoers, controllers: {
    omniauth_callbacks: 'moviegoers/omniauth_callbacks',
    sessions: 'moviegoers/sessions',
    registrations: 'moviegoers/registrations'
    }

  resources :movies do
    resources :reviews, except: [:index, :show] # ไม่ต้องใส่ [:new, :create] ถ้าคุณไม่ต้องการให้มีหน้าสร้างรีวิว
  end
  
  resources :reviews, only: [:new, :create, :edit, :update, :destroy]

  resources :moviegoers do
    resources :reviews
  end
  
  # map '/' to be a redirect to '/movies'
  root :to => redirect('/movies')
  post '/movies/search_tmdb' => 'movies#search_tmdb', :as => 'search_tmdb'
end
