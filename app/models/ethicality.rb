class Ethicality < ApplicationRecord
  belongs_to :listing
  before_save :ensure_slug

  private

  def ensure_slug
    if not self.slug
      self.slug = self.name.parameterize
    end
  end
end
