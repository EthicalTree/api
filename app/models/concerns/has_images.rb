module HasImages
  extend ActiveSupport::Concern

  def make_cover_image img
    self.images.each { |i| i.update_column(:order, i.order + 1) }
    img.update_column(:order, 0)
    self.rebuild_image_order
  end

  def shift_image img1, dir
    imgs = self.images
    dir_n = { previous: -1, next: 1 }[dir.to_sym]
    img2 = imgs[img1.order + dir_n] || imgs[0]
    o1, o2 = img1.order, img2.order
    img1.update_column(:order, o2)
    img2.update_column(:order, o1)
  end

  def rebuild_image_order
    self.images.all.each_with_index do |img, i|
      if img.order != i
        img.update_column(:order, i)
      end
    end
  end
end
