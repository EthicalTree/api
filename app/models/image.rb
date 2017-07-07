class Image < ApplicationRecord
  default_scope { order(order: :desc) }
end

