require 'rails_helper'

RSpec.describe Product, type: :model do

	it "has a valid factory" do
	  expect(build(:product)).to be_valid
	end

	describe "sku" do
		it { should validate_presence_of(:sku) }
		it { should validate_uniqueness_of(:sku) }
	end

	describe "associations" do
		it { should have_many(:warehouses).through(:inventory) }
		it { should have_many(:inventory)}		
		it { should have_many(:shipments).through(:line_items) }
		it { should have_many(:line_items)}
	end
end
