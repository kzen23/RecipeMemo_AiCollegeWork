class Recipe < ApplicationRecord
  # バリデーション
  validates :name, presence: true, length: { maximum: 100 }
  validates :ingredients, presence: true
  validates :instructions, presence: true
  validates :cooking_time, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :servings, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
