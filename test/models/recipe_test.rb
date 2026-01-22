require "test_helper"

class RecipeTest < ActiveSupport::TestCase
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
end
