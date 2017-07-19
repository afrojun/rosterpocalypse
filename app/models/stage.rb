class Stage < ApplicationRecord
  belongs_to :tournament
  has_many :matches, -> { order 'start_date ASC' }
end
