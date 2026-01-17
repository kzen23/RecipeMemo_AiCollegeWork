class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.string :name
      t.text :ingredients
      t.text :instructions
      t.string :category
      t.integer :cooking_time
      t.integer :servings
      t.boolean :favorite
      t.string :image_url

      t.timestamps
    end
  end
end
