require "rails_helper"

RSpec.describe LinksController, type: :controller do
  describe "POST #encode" do
    before { post :encode, params: { url: } }

    context "when the url is valid" do
      let(:url) { "https://google.com" }

      it "returns short_url" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["short_url"]).to be_present
      end
    end

    context "when the url is invalid" do
      let(:url) { "not_a_url" }

      it "returns error" do
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to be_present
      end
    end
  end

  describe "POST #decode" do
    let!(:link) { Link.find_or_create_new_link("https://google.com") }

    before { post :decode, params: { short_code: } }

    context "when the short_code is valid" do
      let(:short_code) { link.short_code }

      it "returns original url" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["url"]).to eq("https://google.com")
      end
    end

    context "when the short_code is invalid" do
      let(:short_code) { "notfound" }

      it "returns error" do
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Not found")
      end
    end
  end
end
