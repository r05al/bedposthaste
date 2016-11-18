class Inventory < ActiveRecord::Base
	validates :warehouse_id, :product_id, presence: true
	validates :warehouse_id, uniqueness: { scope: :product_id }

	belongs_to :warehouse
	belongs_to :product

end
