require "rails_helper"

RSpec.describe Link, type: :model do
  describe "class methods" do
    describe ".find_or_create_new_link" do
      context "when the link is existing before" do
        let!(:link) { create(:link, original_url: "https://www.google.com") }

        it "should return the existing link" do
          expect(Link.find_or_create_new_link("https://www.google.com")).to eq(link)
        end
      end

      context "when the link is not existing before" do
        it "should create a new link" do
          expect { Link.find_or_create_new_link("https://www.google.com") }.to change(Link, :count).by(1)
        end
      end

      context "when the link is created concurrently with the same url" do
         # disable transaction of rspec to test the concurrency
         # because in this case we will retry if ActiveRecord::RecordNotUnique is raise
         # But postgres does not support retry on transaction
        self.use_transactional_tests = false

        let(:url) { "https://google.com" }

        it 'only creates one record when called concurrently with the same url' do
          results = []
          errors = []

          threads = 3.times.map do
            Thread.new do
              begin
                link = Link.find_or_create_new_link(url)
                results << link.id
              rescue ActiveRecord::RecordNotUnique
                errors << :duplicate
              end
            end
          end
          threads.each(&:join)

          expect(Link.where(original_url: url).count).to eq(1)
          expect(results.size).to eq(3)
          expect(results.uniq.size).to eq(1)
          expect(errors.size).to eq 0
        end
      end
    end
  end
end
