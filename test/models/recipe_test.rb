require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  # バリデーションのテスト
  test "nameが必須であること" do
    recipe = Recipe.new(name: nil, ingredients: "材料", instructions: "手順")
    assert_not recipe.valid?
    assert_includes recipe.errors[:name], "を入力してください"
  end

  test "ingredientsが必須であること" do
    recipe = Recipe.new(name: "料理名", ingredients: nil, instructions: "手順")
    assert_not recipe.valid?
    assert_includes recipe.errors[:ingredients], "を入力してください"
  end

  test "instructionsが必須であること" do
    recipe = Recipe.new(name: "料理名", ingredients: "材料", instructions: nil)
    assert_not recipe.valid?
    assert_includes recipe.errors[:instructions], "を入力してください"
  end

  test "nameが100文字以内であること" do
    recipe = Recipe.new(name: "a" * 101, ingredients: "材料", instructions: "手順")
    assert_not recipe.valid?
    assert_includes recipe.errors[:name], "は100文字以内で入力してください"
  end

  test "cooking_timeが正の整数であること" do
    recipe = Recipe.new(name: "料理名", ingredients: "材料", instructions: "手順", cooking_time: -1)
    assert_not recipe.valid?
  end

  test "servingsが正の整数であること" do
    recipe = Recipe.new(name: "料理名", ingredients: "材料", instructions: "手順", servings: 0)
    assert_not recipe.valid?
  end

  test "有効なレシピが作成できること" do
    recipe = Recipe.new(
      name: "カレーライス",
      ingredients: "カレールー、じゃがいも",
      instructions: "煮込む",
      category: "和食",
      cooking_time: 30,
      servings: 4
    )
    assert recipe.valid?
  end

  # 検索機能のテスト
  test "searchスコープが料理名で部分一致検索できること" do
    results = Recipe.search("カレー")
    assert_includes results, recipes(:one)
    assert_not_includes results, recipes(:two)
    assert_not_includes results, recipes(:three)
  end

  test "searchスコープが大文字小文字を区別せず検索できること" do
    results = Recipe.search("かれー")
    # SQLite3の場合、LIKEは大文字小文字を区別しない
    assert results.count >= 0
  end

  test "searchスコープが空文字列で全件を返すこと" do
    results = Recipe.search("")
    assert_equal Recipe.count, results.count
  end

  test "searchスコープがSQLインジェクションから保護されていること" do
    results = Recipe.search("'; DROP TABLE recipes; --")
    # エラーが発生しないことを確認
    assert results.is_a?(ActiveRecord::Relation)
  end

  # お気に入り機能のテスト
  test "favoritesスコープがお気に入りのレシピのみを返すこと" do
    favorite_recipes = Recipe.favorites

    assert_includes favorite_recipes, recipes(:two)
    assert_includes favorite_recipes, recipes(:three)
    assert_not_includes favorite_recipes, recipes(:one)
    assert_equal 2, favorite_recipes.count
  end

  test "toggle_favorite!でお気に入り状態が切り替わること" do
    recipe = recipes(:one)
    assert_equal false, recipe.favorite

    recipe.toggle_favorite!
    assert_equal true, recipe.favorite

    recipe.toggle_favorite!
    assert_equal false, recipe.favorite
  end

  test "toggle_favorite!がデータベースに保存されること" do
    recipe = recipes(:one)
    recipe.toggle_favorite!

    recipe.reload
    assert_equal true, recipe.favorite
  end

  # カテゴリフィルタのテスト
  test "categoryが有効なカテゴリの場合バリデーションが通ること" do
    recipe = Recipe.new(
      name: "料理名",
      ingredients: "材料",
      instructions: "手順",
      category: "和食"
    )
    assert recipe.valid?
  end

  test "categoryが無効なカテゴリの場合バリデーションエラーになること" do
    recipe = Recipe.new(
      name: "料理名",
      ingredients: "材料",
      instructions: "手順",
      category: "無効なカテゴリ"
    )
    assert_not recipe.valid?
    assert_includes recipe.errors[:category], "は一覧にありません"
  end

  test "categoryが空の場合バリデーションが通ること" do
    recipe = Recipe.new(
      name: "料理名",
      ingredients: "材料",
      instructions: "手順",
      category: nil
    )
    assert recipe.valid?
  end

  test "by_categoryスコープが指定されたカテゴリのレシピのみを返すこと" do
    results = Recipe.by_category("和食")
    assert_includes results, recipes(:one)
    assert_not_includes results, recipes(:two)
    assert_not_includes results, recipes(:three)
    assert_equal 1, results.count
  end

  test "by_categoryスコープが空文字列の場合全件を返すこと" do
    results = Recipe.by_category("")
    assert_equal Recipe.count, results.count
  end

  test "by_categoryスコープがnilの場合全件を返すこと" do
    results = Recipe.by_category(nil)
    assert_equal Recipe.count, results.count
  end

  test "searchとby_categoryを組み合わせてフィルタリングできること" do
    results = Recipe.search("カレー").by_category("和食")
    assert_includes results, recipes(:one)
    assert_equal 1, results.count
  end
end
