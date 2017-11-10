class Menu < ApplicationRecord
  belongs_to :listing

  has_many :menu_images
  has_many :images, through: :menu_images, class_name: 'Image'
end

class MenuImage < ApplicationRecord
  belongs_to :menu
  belongs_to :image
end
