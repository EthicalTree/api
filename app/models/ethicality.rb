class Ethicality < ApplicationRecord
  before_save :ensure_slug

  def as_tag_json
  end

  private

  def ensure_slug
    if not self.slug
      self.slug = self.name.parameterize separator: '_'
    end
  end
end
