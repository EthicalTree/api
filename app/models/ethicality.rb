class Ethicality < ApplicationRecord
  before_save :ensure_slug

  def as_tag_json
  end

  def self.by_name name
    slug = {
      'veg-friendly': 'vegetarian',
      'vegetarian': 'vegetarian',
      'vegan': 'vegan',
      'fair trade options': 'fair_trade',
      'fair trade': 'fair_trade',
      'owned by a woman': 'woman_owned',
      'woman-owned': 'woman_owned',
      'organic options': 'organic',
      'organic': 'organic'
    }[name.to_s.downcase.to_sym] || name

    Ethicality.find_by(slug: slug)
  end

  private

  def ensure_slug
    if not self.slug
      self.slug = self.name.parameterize separator: '_'
    end
  end
end
