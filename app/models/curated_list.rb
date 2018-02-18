class CuratedList < ApplicationRecord
  enum location: [:front_page]

  belongs_to :tag
  after_save :ensure_unique_order

  validates :name, presence: true
  validates :tag, presence: true

  private

  def ensure_unique_order
    CuratedList.all.order(:order).each_with_index do |cl, i|
      cl.update_column(:order, i+1)
    end
  end
end
