class Warehouse < ActiveRecord::Base
	validates :name, presence: true, uniqueness: true
	validates :zip, presence: true

	has_many :products, through: :inventory
	has_many :inventory

end
