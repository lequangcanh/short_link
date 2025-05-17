class Link < ApplicationRecord
  SHORT_CODE_LENGTH = 6

  validates :original_url, presence: true, format: { with: URI.regexp }
  validates :original_url_hash, presence: true, uniqueness: true
  validates :short_code, presence: true, uniqueness: true

  before_validation :set_original_url_hash, :generate_short_code, on: :create

  class << self
    def find_or_create_new_link(original_url)
      find_by(original_url_hash: Digest::SHA256.hexdigest(original_url)) || create(original_url: original_url)
    end

    def create(**args)
      retries = 0
      begin
        super
      rescue ActiveRecord::RecordNotUnique
        retries += 1
        retry if retries < 3
      end
    end
  end

  private

  def set_original_url_hash
    self.original_url_hash = Digest::SHA256.hexdigest(original_url)
  end

  def generate_short_code
    loop do
      self.short_code = SecureRandom.alphanumeric(SHORT_CODE_LENGTH)
      break unless Link.exists?(short_code: short_code)
    end
  end
end
