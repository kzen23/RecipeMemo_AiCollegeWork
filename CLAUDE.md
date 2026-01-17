# RecipeMemo - 開発ルール

このドキュメントは、RecipeMemoアプリケーションの開発において、Claude Codeと協働する際の開発ルール、よく使うコマンド、コーディング規約をまとめたものです。

---

## 1. よく使うコマンド

### 1.1 プロジェクト作成・セットアップ

```bash
# Railsプロジェクトの作成
rails new RecipeMemo_AiCollegeWork -d sqlite3

# または PostgreSQL を使用する場合
rails new RecipeMemo_AiCollegeWork -d postgresql

# プロジェクトディレクトリに移動
cd RecipeMemo_AiCollegeWork

# 依存関係のインストール
bundle install

# データベースの作成
rails db:create

# マイグレーションの実行
rails db:migrate

# サーバーの起動
rails server
# または
rails s
```

### 1.2 Scaffoldの使用

```bash
# Recipeモデルのscaffold生成
rails generate scaffold Recipe name:string ingredients:text instructions:text category:string cooking_time:integer servings:integer favorite:boolean image_url:string

# マイグレーションの実行
rails db:migrate
```

### 1.3 マイグレーション

```bash
# マイグレーションファイルの生成
rails generate migration AddColumnToRecipes

# マイグレーション実行
rails db:migrate

# マイグレーションのロールバック（1つ前に戻す）
rails db:rollback

# マイグレーションのロールバック（指定したステップ数戻す）
rails db:rollback STEP=2

# マイグレーションのステータス確認
rails db:migrate:status

# データベースのリセット（開発環境のみ）
rails db:reset
```

### 1.4 モデル・コントローラ・ビューの生成

```bash
# モデルの生成
rails generate model Recipe name:string ingredients:text

# コントローラの生成
rails generate controller Recipes index show new edit

# ビューのみ生成（コントローラ生成時に自動作成されるが、個別に追加も可能）
# app/views/recipes/ に手動で作成
```

### 1.5 ルーティング確認

```bash
# ルーティング一覧を表示
rails routes

# 特定のコントローラのルーティングのみ表示
rails routes | grep recipes

# または
rails routes -c recipes
```

### 1.6 Railsコンソール

```bash
# Railsコンソールの起動
rails console
# または
rails c

# サンドボックスモード（変更を保存しない）
rails console --sandbox

# コンソール内でのレコード操作例
Recipe.all
Recipe.create(name: "カレーライス", ingredients: "カレールー、じゃがいも", instructions: "煮込む")
Recipe.find(1)
Recipe.where(favorite: true)
```

### 1.7 テスト

```bash
# RSpecのインストール（Gemfileに追加後）
rails generate rspec:install

# テストの実行
bundle exec rspec

# 特定のテストファイルを実行
bundle exec rspec spec/models/recipe_spec.rb

# 特定の行のテストを実行
bundle exec rspec spec/models/recipe_spec.rb:10
```

### 1.8 その他

```bash
# アセットのプリコンパイル（本番環境）
rails assets:precompile

# タスク一覧の表示
rails -T

# データベースのシード実行
rails db:seed

# ログの確認
tail -f log/development.log
```

---

## 2. コーディング規約

### 2.1 命名規則

#### モデル
- 単数形、キャメルケース（PascalCase）
- 例: `Recipe`, `User`, `RecipeCategory`

#### コントローラ
- 複数形、キャメルケース、末尾に`Controller`
- 例: `RecipesController`, `UsersController`

#### ビュー
- スネークケース
- 例: `index.html.erb`, `show.html.erb`, `_form.html.erb`

#### 変数・メソッド
- スネークケース
- 例: `cooking_time`, `find_by_name`, `favorite_recipes`

#### 定数
- 大文字スネークケース
- 例: `MAX_COOKING_TIME`, `DEFAULT_SERVINGS`

### 2.2 Rubyのベストプラクティス

```ruby
# 良い例: unless を使って否定条件を読みやすく
redirect_to root_path unless user_signed_in?

# 悪い例: if と否定演算子の組み合わせ
redirect_to root_path if !user_signed_in?

# 良い例: ガード節を使って早期リターン
def show
  @recipe = Recipe.find(params[:id])
  return redirect_to recipes_path unless @recipe
  # 処理続行
end

# 良い例: シンボルハッシュ記法
{ name: "カレー", category: "和食" }

# 良い例: 文字列補完
"#{recipe.name} の調理時間は #{recipe.cooking_time} 分です"
```

### 2.3 Railsのベストプラクティス

#### モデル

```ruby
class Recipe < ApplicationRecord
  # 定数は最初に定義
  CATEGORIES = %w[和食 洋食 中華 その他].freeze

  # アソシエーションは次に定義
  # has_many :reviews

  # バリデーションはアソシエーションの後
  validates :name, presence: true, length: { maximum: 100 }
  validates :ingredients, presence: true
  validates :instructions, presence: true
  validates :cooking_time, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :servings, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true

  # スコープの定義
  scope :favorites, -> { where(favorite: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }

  # クラスメソッド
  def self.search(query)
    where("name LIKE ?", "%#{query}%")
  end

  # インスタンスメソッド
  def toggle_favorite!
    update(favorite: !favorite)
  end
end
```

#### コントローラ

```ruby
class RecipesController < ApplicationController
  # before_action は最初に定義
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  def index
    @recipes = Recipe.all
  end

  def show
  end

  def new
    @recipe = Recipe.new
  end

  def create
    @recipe = Recipe.new(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: 'レシピが作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: 'レシピが更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_url, notice: 'レシピが削除されました。'
  end

  private

  # private メソッドは最後に定義
  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:name, :ingredients, :instructions, :category, :cooking_time, :servings, :favorite, :image_url)
  end
end
```

#### ビュー

```erb
<!-- パーシャルを使って共通部分を切り出す -->
<%= render 'form', recipe: @recipe %>

<!-- ヘルパーメソッドを活用 -->
<%= link_to 'レシピ一覧', recipes_path, class: 'btn btn-primary' %>

<!-- 条件分岐を簡潔に -->
<% if @recipe.favorite? %>
  <span class="badge bg-warning">お気に入り</span>
<% end %>

<!-- 繰り返し処理 -->
<% @recipes.each do |recipe| %>
  <div class="card">
    <h3><%= recipe.name %></h3>
    <p>調理時間: <%= recipe.cooking_time %>分</p>
  </div>
<% end %>
```

### 2.4 Git コミットメッセージ規約

```bash
# フォーマット
[種類] 簡潔な説明

# 種類
# feat: 新機能
# fix: バグ修正
# docs: ドキュメントのみの変更
# style: コードの意味に影響しない変更（空白、フォーマット等）
# refactor: バグ修正や機能追加ではないコード変更
# test: テストの追加や修正
# chore: ビルドプロセスやツールの変更

# 例
git commit -m "feat: レシピ一覧ページの実装"
git commit -m "fix: お気に入り機能のバグ修正"
git commit -m "docs: READMEの更新"
git commit -m "test: Recipeモデルのテスト追加"
```

---

## 3. プロジェクト構成

```
RecipeMemo_AiCollegeWork/
├── app/
│   ├── controllers/
│   │   └── recipes_controller.rb
│   ├── models/
│   │   └── recipe.rb
│   ├── views/
│   │   └── recipes/
│   │       ├── index.html.erb
│   │       ├── show.html.erb
│   │       ├── new.html.erb
│   │       ├── edit.html.erb
│   │       └── _form.html.erb
│   └── helpers/
│       └── recipes_helper.rb
├── config/
│   ├── routes.rb
│   └── database.yml
├── db/
│   ├── migrate/
│   │   └── YYYYMMDDHHMMSS_create_recipes.rb
│   └── schema.rb
├── spec/
│   ├── models/
│   │   └── recipe_spec.rb
│   ├── requests/
│   │   └── recipes_spec.rb
│   └── factories/
│       └── recipes.rb
├── docs/
│   └── design.md
├── Gemfile
├── CLAUDE.md (このファイル)
└── README.md
```

---

## 4. テスト方針

### 4.1 モデルテスト

```ruby
# spec/models/recipe_spec.rb
require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'バリデーション' do
    it '有効なファクトリを持つこと' do
      expect(build(:recipe)).to be_valid
    end

    it '料理名がなければ無効であること' do
      recipe = build(:recipe, name: nil)
      expect(recipe).not_to be_valid
      expect(recipe.errors[:name]).to include("can't be blank")
    end

    it '料理名が100文字を超えると無効であること' do
      recipe = build(:recipe, name: 'a' * 101)
      expect(recipe).not_to be_valid
    end
  end

  describe 'スコープ' do
    it 'お気に入りのレシピのみ取得できること' do
      favorite = create(:recipe, favorite: true)
      normal = create(:recipe, favorite: false)
      expect(Recipe.favorites).to include(favorite)
      expect(Recipe.favorites).not_to include(normal)
    end
  end
end
```

### 4.2 リクエストテスト

```ruby
# spec/requests/recipes_spec.rb
require 'rails_helper'

RSpec.describe "Recipes", type: :request do
  describe "GET /recipes" do
    it "成功すること" do
      get recipes_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /recipes" do
    context "有効なパラメータの場合" do
      it "レシピが作成されること" do
        expect {
          post recipes_path, params: { recipe: attributes_for(:recipe) }
        }.to change(Recipe, :count).by(1)
      end
    end
  end
end
```

---

## 5. 開発フロー

### 5.1 機能開発の流れ

1. ブランチを切る
   ```bash
   git checkout -b feature/recipe-search
   ```

2. 実装
   - モデルの変更（マイグレーション、バリデーション）
   - コントローラの変更
   - ビューの変更
   - テストの追加

3. テスト実行
   ```bash
   bundle exec rspec
   ```

4. コミット
   ```bash
   git add .
   git commit -m "feat: レシピ検索機能の実装"
   ```

5. プッシュ
   ```bash
   git push origin feature/recipe-search
   ```

6. メインブランチにマージ
   ```bash
   git checkout main
   git merge feature/recipe-search
   ```

---

## 6. トラブルシューティング

### 6.1 よくあるエラー

#### マイグレーションエラー
```bash
# データベースをリセット
rails db:drop db:create db:migrate

# 開発環境のみ、データも再投入
rails db:reset db:seed
```

#### サーバーが起動しない
```bash
# ポートが使用中の場合
kill -9 $(lsof -ti:3000)

# または別のポートで起動
rails s -p 3001
```

#### Bundlerのエラー
```bash
# Gemfileを変更した後は必ず実行
bundle install

# Gemのバージョンが合わない場合
bundle update
```

---

## 7. 開発環境

### 推奨バージョン
- Ruby: 3.2以上
- Rails: 7.1以上
- Node.js: 18以上（Asset管理用）

### エディタ設定
- インデント: スペース2つ
- 文字コード: UTF-8
- 改行コード: LF（Linux/Mac）、CRLF（Windows）
- 行末の空白: 削除

---

## 8. Claude Codeとの協働ガイドライン

### 8.1 依頼の仕方

明確で具体的な指示を出す
```
良い例:
「Recipeモデルにお気に入り機能を追加してください。
favoriteカラム（boolean）を追加し、デフォルト値はfalseにしてください。」

悪い例:
「お気に入り機能をつけて」
```

### 8.2 レビューポイント

Claude Codeが生成したコードは以下をチェック
- バリデーションが適切か
- セキュリティ上の問題がないか
- テストが含まれているか
- 命名規則に従っているか

### 8.3 段階的な開発

大きな機能は段階的に依頼する
1. モデルとマイグレーション
2. コントローラとルーティング
3. ビュー
4. テスト

---

## 9. 参考リンク

- [Ruby on Rails ガイド](https://railsguides.jp/)
- [RSpec ドキュメント](https://rspec.info/)
- [Ruby Style Guide](https://rubystyle.guide/)
- [Rails Style Guide](https://rails.rubystyle.guide/)

---

最終更新: 2026-01-17
