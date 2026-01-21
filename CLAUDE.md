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

#### Minitest（現在使用中）

```bash
# 全テスト実行
rails test

# モデルテストのみ実行
rails test:models

# コントローラテストのみ実行
rails test:controllers

# 特定のテストファイルを実行
rails test test/models/recipe_test.rb

# 特定の行のテストを実行
rails test test/models/recipe_test.rb:10
```

#### RSpec（将来的に移行する場合）

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

**注**: 以下の例はRSpecを使用した場合のテスト例です。現在のプロジェクトではMinitestを使用していますが、将来的にRSpecに移行する際の参考としてください。

### 4.1 モデルテスト（RSpec使用時）

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

### 4.2 リクエストテスト（RSpec使用時）

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
   rails test
   # または、RSpec使用時は bundle exec rspec
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

## 10. プロジェクト固有の情報

### 10.1 現在の技術スタック

このプロジェクトで実際に使用しているバージョン:
- **Ruby**: 3.2.0
- **Rails**: 7.1.6
- **データベース**: SQLite3
- **フロントエンド**: Hotwire (Turbo Rails, Stimulus)
- **テストフレームワーク**: Minitest（デフォルト）※RSpecは未導入

### 10.2 実装済みの機能

**Recipeモデル**
- scaffold で基本的なCRUD機能を実装済み
- カラム: name, ingredients, instructions, category, cooking_time, servings, favorite, image_url
- 現在のバリデーション: name, ingredients, instructions の presence、cooking_time と servings の numericality

**ビュー**
- index.html.erb（一覧）
- show.html.erb（詳細）
- new.html.erb（新規作成）
- edit.html.erb（編集）
- _form.html.erb（フォーム部分）
- _recipe.html.erb（レシピ部分テンプレート）

**コントローラ**
- RecipesController で基本的なCRUD操作を実装
- JSON API にも対応（respond_to ブロック使用）

### 10.3 Windows環境での開発

このプロジェクトはWindows環境（Git Bash）で開発しています。

#### パスの扱い
```bash
# Git Bashではスラッシュを使用
cd /c/Users/kn022/RecipeMemo/RecipeMemo_AiCollegeWork

# Windowsのパスはバックスラッシュだが、Git Bashでは自動変換される
# コマンド実行時はスラッシュで統一する
```

#### サーバー起動時の注意
```bash
# Windows環境でサーバーが既に起動している場合
# タスクマネージャーでruby.exeプロセスを終了するか、
# 以下のコマンドでPIDを確認して終了
cat tmp/pids/server.pid
# PIDを使ってプロセスを終了
taskkill /PID <PID> /F

# または別のポートで起動
rails s -p 3001
```

#### Git Bashでの注意点
```bash
# コマンドはLinux形式で実行可能
rails routes | grep recipes

# ただし、Windowsネイティブのコマンドを使う場合は注意
# 例: psの代わりにtasklistを使用
tasklist | findstr ruby
```

### 10.4 日本語化の設定（実装例）

**注**: 以下は未実装の設定例です。scaffold で生成されたメッセージは現在英語のままですが、日本語化する場合は以下を実施してください。

#### config/application.rb に追加
```ruby
module RecipeMemoAiCollegeWork
  class Application < Rails::Application
    config.load_defaults 7.1

    # 日本語化設定
    config.i18n.default_locale = :ja
    config.time_zone = 'Tokyo'
  end
end
```

#### config/locales/ja.yml を作成
```yaml
ja:
  activerecord:
    models:
      recipe: レシピ
    attributes:
      recipe:
        name: 料理名
        ingredients: 材料
        instructions: 作り方
        category: カテゴリ
        cooking_time: 調理時間
        servings: 人数
        favorite: お気に入り
        image_url: 画像URL
    errors:
      messages:
        blank: を入力してください
        too_long: は%{count}文字以内で入力してください
        greater_than: は%{count}より大きい値にしてください
```

#### コントローラのメッセージを日本語化
```ruby
# app/controllers/recipes_controller.rb
def create
  @recipe = Recipe.new(recipe_params)

  respond_to do |format|
    if @recipe.save
      format.html { redirect_to @recipe, notice: "レシピを作成しました。" }
      format.json { render :show, status: :created, location: @recipe }
    else
      format.html { render :new, status: :unprocessable_entity }
      format.json { render json: @recipe.errors, status: :unprocessable_entity }
    end
  end
end
```

### 10.5 モデルの拡張方法（実装例）

**注**: 以下は未実装の拡張例です。現在のRecipeモデルは基本的なバリデーションのみですが、以下のような拡張が可能です。

#### 定数の追加
```ruby
class Recipe < ApplicationRecord
  # カテゴリの選択肢を定数で定義
  CATEGORIES = %w[和食 洋食 中華 その他].freeze

  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true
end
```

#### スコープの追加
```ruby
class Recipe < ApplicationRecord
  # お気に入りのレシピのみ取得
  scope :favorites, -> { where(favorite: true) }

  # カテゴリで絞り込み
  scope :by_category, ->(category) { where(category: category) }

  # 最近作成されたものから順に取得
  scope :recent, -> { order(created_at: :desc) }

  # 調理時間が短い順
  scope :quick, -> { where.not(cooking_time: nil).order(cooking_time: :asc) }
end
```

#### インスタンスメソッドの追加
```ruby
class Recipe < ApplicationRecord
  # お気に入りをトグル
  def toggle_favorite!
    update(favorite: !favorite)
  end

  # 調理時間を分単位で表示
  def cooking_time_in_minutes
    return "未設定" if cooking_time.nil?
    "#{cooking_time}分"
  end

  # 何人分かを表示
  def servings_text
    return "未設定" if servings.nil?
    "#{servings}人分"
  end
end
```

#### クラスメソッドの追加
```ruby
class Recipe < ApplicationRecord
  # レシピ名で検索
  def self.search(query)
    return all if query.blank?
    where("name LIKE ?", "%#{query}%")
  end

  # 人気のレシピ（お気に入りが多い順）
  def self.popular
    favorites.recent.limit(10)
  end
end
```

### 10.6 JSON API対応

scaffold で生成されたコントローラは JSON API にも対応しています:

```ruby
# GET /recipes.json でJSON形式のレシピ一覧を取得可能
# POST /recipes.json でJSON形式でレシピを作成可能

# curlでのテスト例
curl http://localhost:3000/recipes.json

# JSON形式でレシピを作成
curl -X POST http://localhost:3000/recipes.json \
  -H "Content-Type: application/json" \
  -d '{"recipe":{"name":"カレーライス","ingredients":"カレールー","instructions":"煮込む"}}'
```

#### Jbuilder ビュー
- app/views/recipes/index.json.jbuilder
- app/views/recipes/show.json.jbuilder

これらのファイルでJSON出力形式をカスタマイズ可能

### 10.7 テストフレームワークの選択

現在はRailsデフォルトの**Minitest**を使用しています。

#### Minitestでのテスト実行
```bash
# 全テスト実行
rails test

# モデルテストのみ実行
rails test:models

# コントローラテストのみ実行
rails test:controllers

# 特定のテストファイルを実行
rails test test/models/recipe_test.rb
```

#### RSpecに移行する場合
```bash
# Gemfile に追加
# group :development, :test do
#   gem 'rspec-rails', '~> 6.0'
#   gem 'factory_bot_rails'
# end

bundle install
rails generate rspec:install

# 既存のMinitestファイルは削除可能
# rm -rf test/
```

### 10.8 開発時のヒント

#### デバッグ
```ruby
# コントローラやモデルでデバッグ出力
Rails.logger.debug "Recipe: #{@recipe.inspect}"

# binding.irbで対話的デバッグ（Rails 7.1）
def create
  @recipe = Recipe.new(recipe_params)
  binding.irb  # ここで処理が止まり、irb起動
  @recipe.save
end
```

#### データのシード（実装例）
```ruby
# db/seeds.rb にサンプルデータを追加
# 注: Recipe::CATEGORIES は未実装のため、実際に使用する場合は先にモデルに定数を追加してください
10.times do |i|
  Recipe.create!(
    name: "レシピ #{i + 1}",
    ingredients: "材料A、材料B",
    instructions: "手順1、手順2",
    category: ["和食", "洋食", "中華", "その他"].sample,
    cooking_time: rand(10..60),
    servings: rand(2..4),
    favorite: [true, false].sample
  )
end

# シード実行
rails db:seed
```

#### ルーティングのカスタマイズ（実装例）
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :recipes do
    # お気に入りトグル用のルート追加例
    member do
      patch :toggle_favorite
    end

    # カテゴリ別一覧用のルート追加例
    collection do
      get :favorites
      get 'category/:category', action: :by_category, as: :by_category
    end
  end

  root "recipes#index"
end
```

### 10.9 よくある追加機能の実装パターン（実装例）

**注**: 以下は未実装の機能例です。Phase 2以降で実装を検討する際の参考としてください。

#### 検索機能の追加
```ruby
# app/controllers/recipes_controller.rb
def index
  @recipes = if params[:query].present?
               Recipe.search(params[:query])
             else
               Recipe.all
             end
end

# app/models/recipe.rb
scope :search, ->(query) { where("name LIKE ?", "%#{query}%") }
```

#### ページネーション（kaminari gem使用）
```ruby
# Gemfile
gem 'kaminari'

# app/controllers/recipes_controller.rb
def index
  @recipes = Recipe.page(params[:page]).per(10)
end

# app/views/recipes/index.html.erb
<%= paginate @recipes %>
```

#### 画像アップロード（Active Storage使用）
```bash
rails active_storage:install
rails db:migrate
```

```ruby
# app/models/recipe.rb
class Recipe < ApplicationRecord
  has_one_attached :image
end

# app/views/recipes/_form.html.erb
<%= form.file_field :image %>

# app/controllers/recipes_controller.rb
def recipe_params
  params.require(:recipe).permit(:name, :ingredients, :instructions, :image)
end
```

---

最終更新: 2026-01-17
