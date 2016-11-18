class Shipment < ActiveRecord::Base
	validates :zip, presence: true

	has_many :products, through: :line_items
	has_many :line_items, dependent: :destroy

end
