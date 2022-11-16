Rails.application.routes.draw do
  resource :pricing, only: [:show]
end
