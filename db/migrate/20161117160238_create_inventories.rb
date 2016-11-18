class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.integer :warehouse_id
      t.integer :product_id
      t.integer :quantity, default: 0

      t.timestamps null: false
    end
  end
end
