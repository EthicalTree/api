class SeoPath < ApplicationRecord
  before_validation :strip_url

  validates :path, presence: true, uniqueness: true

  def strip_url
    self.path = SeoPath.strip_url(self.path)
  end

  def self.strip_url url
    uri = URI::parse(url)
    uri.path.downcase
  end
end
