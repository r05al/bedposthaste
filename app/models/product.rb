class Product < ActiveRecord::Base
	validates :sku, presence: true, uniqueness: true

	has_many :warehouses, through: :inventory
	has_many :inventory

	has_many :shipments, through: :line_items
	has_many :line_items

end
