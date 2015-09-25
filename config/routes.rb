SwankDB::Application.routes.draw do

  get "entries/suggest_tags" => "entries#suggest_tags"
  get "entries/preview" => "entries#preview"
  get "entries/download" => "entries#download"
  get "users/login" => "users#login"
  post "users/login" => "users#login"
  get "users/logout" => "users#logout"
  get "users/invite" => "users#invite"
  get "users/reset_password" => "users#reset_password"
  get "users/instant" => "users#instant"
  get "users/syndication" => "users#syndication"
  get "ical/created" => "ical#created"
  get "ical/updated" => "ical#updated"

  resources :entries
  resources :users
  resources :about

  root :to => "about#index"

end
