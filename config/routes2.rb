(in /home/alexmchale/src/swankdb)
Swankdb::Application.routes.draw do
  match 'entries/suggest_tags' => 'entries#suggest_tags'
  match 'entries/preview' => 'entries#preview'
  match 'entries/download' => 'entries#download'
  match 'users/login' => 'users#login'
  match 'users/logout' => 'users#logout'
  match 'users/invite' => 'users#invite'
  match 'users/reset_password' => 'users#reset_password'
  match 'users/instant' => 'users#instant'
  match 'users/syndication' => 'users#syndication'
  match 'ical/created' => 'ical#created'
  match 'ical/updated' => 'ical#updated'
  resources :entries
  resources :users
  resources :about
  match '/' => 'about#index'
  match '/:controller(/:action(/:id))'
  match ':controller/:action.:format' => '#index'
end
