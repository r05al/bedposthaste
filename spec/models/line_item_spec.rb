require 'rails_helper'

RSpec.describe LineItem, type: :model do
	let(:sh) { FactoryGirl.create(:shipment) }
	let(:p) { FactoryGirl.create(:product) }

	describe "shipment id" do
		it { should validate_presence_of(:shipment_id)}
		it { should validate_uniqueness_of(:shipment_id).scoped_to(:product_id) }
	end

	describe "product id" do
		it { should validate_presence_of(:product_id)}
	end

	describe "associations" do
		it { should belong_to(:shipment) }
		it { should belong_to(:product) }
	end

	it "has default quantity of zero" do #should this be 1?
		li = LineItem.create(shipment_id: sh.id, product_id: p.id)

		expect(li.quantity).to be == 0
	end
end
