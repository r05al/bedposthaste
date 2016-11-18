require 'rails_helper'

RSpec.describe Product, type: :model do

	describe "sku" do
		it { should validate_presence_of(:sku) }
		it { should validate_uniqueness_of(:sku) }
	end

	describe "weight" do
	end

	describe "total_inventory_count" do
		#inv mgmt system Invent
	end

	describe "associations" do
		it { should have_many(:warehouses).through(:inventory) }
		it { should have_many(:inventory)}
	end

end
