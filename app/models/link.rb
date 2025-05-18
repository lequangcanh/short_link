class Link < ApplicationRecord
  SHORT_CODE_LENGTH = 6

  validates :original_url, presence: true, format: { with: URI.regexp }

  before_validation :set_original_url_hash, :generate_short_code, on: :create

  class << self
    def find_or_create_new_link(original_url)
      retries = 0
      begin
        find_by(original_url_hash: Digest::SHA256.hexdigest(original_url)) || create(original_url: original_url)
      rescue ActiveRecord::RecordNotUnique
        # Sometimes, 2 same original_url maybe create at a same time
        # Or 2 same short_code maybe generate and create at a same time
        # So we need retry to make sure it works well
        retries += 1
        retry if retries < 5
        raise
      end
    end
  end

  def short_url
    "#{ENV['APP_DOMAIN']}/#{short_code}"
  end

  private

  def set_original_url_hash
    return if original_url.blank?

    self.original_url_hash = Digest::SHA256.hexdigest(original_url)
  end

  def generate_short_code
    loop do
      self.short_code = SecureRandom.alphanumeric(SHORT_CODE_LENGTH)
      break unless Link.exists?(short_code: short_code)
    end
  end
end
