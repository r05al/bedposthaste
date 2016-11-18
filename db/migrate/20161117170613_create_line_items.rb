class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :shipment_id
      t.integer :product_id
      t.integer :quantity, default: 0

      t.timestamps null: false
    end
  end
end
