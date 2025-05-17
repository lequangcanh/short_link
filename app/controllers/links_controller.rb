class LinksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:encode, :decode]

  def index; end

  def encode
    url = params[:url]
    return render json: { error: "Missing url" }, status: :bad_request unless url.present?

    link = Link.find_or_create_new_link(url)

    if link.valid?
      render json: { short_url: link.short_url }
    else
      render json: { error: link.errors.full_messages.join(", ") }, status: :bad_request
    end
  end

  def decode
    if link = Link.find_by(short_code: params[:short_code])
      render json: { url: link.original_url }
    else
      render json: { error: "Not found" }, status: :not_found
    end
  end
end
