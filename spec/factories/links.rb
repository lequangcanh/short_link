FactoryBot.define do
  factory :link do
    original_url { Faker::Internet.url }
  end
end
