require 'rails_helper'

RSpec.describe Inventory, type: :model do
	let(:wh) { FactoryGirl.create(:warehouse) }
	let(:p) { FactoryGirl.create(:product) }

	describe "warehouse id" do
		it { should validate_presence_of(:warehouse_id)}
		it { should validate_uniqueness_of(:warehouse_id).scoped_to(:product_id) }
	end

	describe "product id" do
		it { should validate_presence_of(:product_id)}
	end

	describe "associations" do
		it { should belong_to(:warehouse) }
		it { should belong_to(:product) }
	end

	it "has default quantity of zero" do
		inv = Inventory.create(warehouse_id: wh.id, product_id: p.id)

		expect(inv.quantity).to be == 0
	end
	
	describe "update" do
		it "updates inventory records" do

		end

	end
end
