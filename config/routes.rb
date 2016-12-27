Rails.application.routes.draw do
  match 'what_to_watch/display' => 'what_to_watch#display', via: [:get, :post], as: 'what_to_watch'

  # You can have the root of your site routed with "root"
  root 'what_to_watch#index'
end
