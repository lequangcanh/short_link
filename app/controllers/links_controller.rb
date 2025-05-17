class LinksController < ApplicationController
  def encode
    url = params[:url]
    return render json: { error: "Missing url" }, status: :bad_request unless url.present?

    short_link = Link.find_or_create_new_link(url)

    if short_link.valid?
      render json: { short_url: "#{ENV['APP_DOMAIN']}/#{short_link.short_code}" }
    else
      render json: { error: short_link.errors.full_messages.join(", ") }, status: :bad_request
    end
  end

  def decode
    if short_link = Link.find_by(short_code: params[:short_code])
      render json: { url: short_link.original_url }
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end
end
