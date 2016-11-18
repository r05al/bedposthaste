class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.integer :warehouse_id
      t.string :zip
      t.boolean :fulfilled, default: false

      t.timestamps null: false
    end
  end
end
