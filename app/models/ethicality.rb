class Ethicality < ApplicationRecord
  before_save :ensure_slug

  private

  def ensure_slug
    if not self.slug
      self.slug = self.name.parameterize separator: '_'
    end
  end
end
