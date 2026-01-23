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

  # カテゴリフィルタのテスト
  test "should filter recipes by category" do
    get recipes_url, params: { category: "和食" }
    assert_response :success
    assert_select "h5.card-title", text: /カレーライス/
    assert_select "strong", text: "和食"
  end

  test "should show all recipes when category is empty" do
    get recipes_url, params: { category: "" }
    assert_response :success
  end

  test "should show no results message when no recipes match category" do
    get recipes_url, params: { category: "その他" }
    assert_response :success
    assert_select ".alert-info", text: /一致するレシピが見つかりませんでした/
  end

  test "should filter recipes by both query and category" do
    get recipes_url, params: { query: "カレー", category: "和食" }
    assert_response :success
    assert_select "h5.card-title", text: /カレーライス/
  end

  # ページネーション機能のテスト
  test "should paginate recipes" do
    # 15件のレシピを作成（1ページ10件なので2ページ目が必要）
    15.times do |i|
      Recipe.create!(
        name: "テストレシピ#{i + 1}",
        ingredients: "材料#{i + 1}",
        instructions: "作り方#{i + 1}"
      )
    end

    # 1ページ目を取得
    get recipes_url, params: { page: 1 }
    assert_response :success

    # 2ページ目を取得
    get recipes_url, params: { page: 2 }
    assert_response :success
  end

  test "should limit recipes to 10 per page" do
    # 15件のレシピを作成
    15.times do |i|
      Recipe.create!(
        name: "テストレシピ#{i + 1}",
        ingredients: "材料#{i + 1}",
        instructions: "作り方#{i + 1}"
      )
    end

    get recipes_url
    assert_response :success

    # 1ページに表示されるレシピ数が10件以下であることを確認
    assert_select ".col", maximum: 10
  end

  test "should paginate favorites" do
    # お気に入りのレシピを15件作成
    15.times do |i|
      Recipe.create!(
        name: "お気に入りレシピ#{i + 1}",
        ingredients: "材料#{i + 1}",
        instructions: "作り方#{i + 1}",
        favorite: true
      )
    end

    # 1ページ目を取得
    get favorites_recipes_url, params: { page: 1 }
    assert_response :success

    # 2ページ目を取得
    get favorites_recipes_url, params: { page: 2 }
    assert_response :success
  end
end
