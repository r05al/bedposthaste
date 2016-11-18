class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :sku
      t.decimal :weight, precision: 5, scale: 4

      t.timestamps null: false
    end
  end
end
