require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recipe = recipes(:one)
  end

  test "should get index" do
    get recipes_url
    assert_response :success
  end

  test "should get new" do
    get new_recipe_url
    assert_response :success
  end

  test "should create recipe" do
    assert_difference("Recipe.count") do
      post recipes_url, params: { recipe: { category: @recipe.category, cooking_time: @recipe.cooking_time, favorite: @recipe.favorite, image_url: @recipe.image_url, ingredients: @recipe.ingredients, instructions: @recipe.instructions, name: @recipe.name, servings: @recipe.servings } }
    end

    assert_redirected_to recipe_url(Recipe.last)
  end

  test "should show recipe" do
    get recipe_url(@recipe)
    assert_response :success
  end

  test "should get edit" do
    get edit_recipe_url(@recipe)
    assert_response :success
  end

  test "should update recipe" do
    patch recipe_url(@recipe), params: { recipe: { category: @recipe.category, cooking_time: @recipe.cooking_time, favorite: @recipe.favorite, image_url: @recipe.image_url, ingredients: @recipe.ingredients, instructions: @recipe.instructions, name: @recipe.name, servings: @recipe.servings } }
    assert_redirected_to recipe_url(@recipe)
  end

  test "should destroy recipe" do
    assert_difference("Recipe.count", -1) do
      delete recipe_url(@recipe)
    end

    assert_redirected_to recipes_url
  end

  # 検索機能のテスト
  test "should search recipes by query" do
    get recipes_url, params: { query: "カレー" }
    assert_response :success
    assert_select "h5.card-title", text: /カレーライス/
    assert_select "strong", text: "カレー"
  end

  test "should show all recipes when query is empty" do
    get recipes_url, params: { query: "" }
    assert_response :success
  end

  test "should show no results message when no recipes match" do
    get recipes_url, params: { query: "存在しない料理名" }
    assert_response :success
    assert_select ".alert-info", text: /一致するレシピが見つかりませんでした/
  end

  # お気に入り機能のテスト
  test "should toggle favorite" do
    recipe = recipes(:one)
    assert_equal false, recipe.favorite

    patch toggle_favorite_recipe_url(recipe)
    recipe.reload
    assert_equal true, recipe.favorite
    assert_redirected_to recipes_url
  end

  test "should get favorites" do
    get favorites_recipes_url
    assert_response :success

    # お気に入りのレシピのみが含まれることを確認
    assert_select "h5.card-title", text: /ハンバーグ/
    assert_select "h5.card-title", text: /チャーハン/
  end
end
