Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "links#index"

  post "/encode", to: "links#encode"
  post "/decode", to: "links#decode"
end
