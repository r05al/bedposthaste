class LineItem < ActiveRecord::Base
	validates :shipment_id, :product_id, presence: true
	validates :shipment_id, uniqueness: { scope: :product_id } 

	belongs_to :shipment
	belongs_to :product
end
