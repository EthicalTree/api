class Image < ApplicationRecord
  default_scope { order(order: :asc) }
end

