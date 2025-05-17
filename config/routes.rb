Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "/encode", to: "links#encode"
  post "/decode", to: "links#decode"
end
