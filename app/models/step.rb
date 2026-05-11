class Step < ApplicationRecord
  belongs_to :recipe

  validates :body, presence: true
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
