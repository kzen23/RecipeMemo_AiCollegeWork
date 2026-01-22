class Recipe < ApplicationRecord
  # バリデーション
  validates :name, presence: true, length: { maximum: 100 }
  validates :ingredients, presence: true
  validates :instructions, presence: true
  validates :cooking_time, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :servings, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  # スコープ
  # 料理名で検索（部分一致）
  scope :search, ->(query) { where("name LIKE ?", "%#{sanitize_sql_like(query)}%") }
  # お気に入りのレシピのみ取得
  scope :favorites, -> { where(favorite: true) }

  # インスタンスメソッド
  # お気に入りをトグル
  def toggle_favorite!
    update(favorite: !favorite)
  end
end
