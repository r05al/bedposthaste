require 'rails_helper'

RSpec.describe Dispatcher, type: :model do

	#warehouses
	let!(:wh1) { FactoryGirl.create(:warehouse) }
	let!(:wh2) { FactoryGirl.create(:warehouse) }
	let!(:wh3) { FactoryGirl.create(:warehouse) }
	let!(:wh4) { FactoryGirl.create(:warehouse) }
	#products
	let!(:p1) { FactoryGirl.create(:product) }
	let!(:p2) { FactoryGirl.create(:product) }
	#shipments
	let!(:sh1) { FactoryGirl.create(:shipment) }
	let!(:sh2) { FactoryGirl.create(:shipment) }
	let!(:sh3) { FactoryGirl.create(:shipment) }
	let!(:sh4) { FactoryGirl.create(:shipment) }

	context "on initalization" do
		it "gets shipments with warehouse_id set to nil" do
			sh2.update(warehouse_id: wh1.id)
			d = Dispatcher.new

			expect(d.shipments).to match_array([sh1, sh3, sh4])
		end

		it "gets warehouses ordered by zip code" do
			d = Dispatcher.new
			
			expect(d.warehouses[0].zip).to be <= d.warehouses[1].zip
			expect(d.warehouses[1].zip).to be <= d.warehouses[2].zip
			expect(d.warehouses[2].zip).to be <= d.warehouses[3].zip
		end
	end
	
	describe "#allocate" do
		it "assigns shipments to warehouses" do
			d = Dispatcher.new

			expect(d).to receive(:assign).with(sh1)
			expect(d).to receive(:assign).with(sh2)
			d.allocate([sh1,sh2])
		end

		it "does not reallocate if it finds a warehouse that can fulfill all shipment items" do
			Inventory.create(warehouse_id: wh1.id, product_id: p1.id, quantity: 3)
			LineItem.create(shipment_id: sh1.id, product_id: p1.id, quantity: 1)
			LineItem.create(shipment_id: sh2.id, product_id: p1.id, quantity: 2)
			d = Dispatcher.new

			expect(d).to_not receive(:reallocate).with(sh1)
			expect(d).to_not receive(:reallocate).with(sh2)
			d.allocate([sh1,sh2])
		end

		it "reallocates shipments if warehouses do not have all shipment line items" do
			Inventory.create(warehouse_id: wh1.id, product_id: p1.id, quantity: 2)
			LineItem.create(shipment_id: sh1.id, product_id: p1.id, quantity: 1)
			LineItem.create(shipment_id: sh2.id, product_id: p1.id, quantity: 2)
			d = Dispatcher.new

			expect(d).to_not receive(:reallocate).with(sh1)
			expect(d).to receive(:reallocate).with(sh2)
			d.allocate([sh1,sh2])
		end

	end	

	describe "#assign checks to the closest warehouses based on zip code" do
		context "when it identifies a warehouse with all shipment line items" do
			it "returns true" do
				LineItem.create(shipment_id: sh1.id, product_id: p1.id, quantity: 1)
				LineItem.create(shipment_id: sh2.id, product_id: p1.id, quantity: 1)
				LineItem.create(shipment_id: sh3.id, product_id: p1.id, quantity: 1)
				Inventory.create(warehouse_id: wh1.id, product_id: p1.id, quantity: 1)
				Inventory.create(warehouse_id: wh2.id, product_id: p1.id, quantity: 2)
				d = Dispatcher.new

				expect(d.assign(sh1)).to be true
				expect(d.assign(sh2)).to be true
				expect(d.assign(sh3)).to be true
			end

			it "assigns to the the shipments closest warehouse where its line items are available" do
				sh1.update(zip: "00050")
				sh2.update(zip: "00050")
				sh3.update(zip: "80000")
				sh4.update(zip: "00050")
				wh1.update(zip: "00000")
				wh2.update(zip: "69999")
				wh3.update(zip: "70000")
				wh4.update(zip: "90000")
				LineItem.create(shipment_id: sh1.id, product_id: p1.id, quantity: 1)
				LineItem.create(shipment_id: sh2.id, product_id: p1.id, quantity: 1)
				LineItem.create(shipment_id: sh3.id, product_id: p1.id, quantity: 1)
				LineItem.create(shipment_id: sh4.id, product_id: p1.id, quantity: 1)
				Inventory.create(warehouse_id: wh1.id, product_id: p1.id, quantity: 1)
				Inventory.create(warehouse_id: wh2.id, product_id: p1.id, quantity: 1)
				Inventory.create(warehouse_id: wh3.id, product_id: p1.id, quantity: 1)
				Inventory.create(warehouse_id: wh4.id, product_id: p1.id, quantity: 1)
				d = Dispatcher.new

				d.assign(sh1)
				d.assign(sh2)
				d.assign(sh3)
				d.assign(sh4)

				expect(sh1.warehouse_id).to eq(wh1.id)
				expect(sh2.warehouse_id).to eq(wh2.id)
				expect(sh3.warehouse_id).to eq(wh4.id) #searches up first
				expect(sh4.warehouse_id).to eq(wh3.id)
			end
		end

		context "when no warehouse has all shipment line items" do
			it "returns false if no warehouse has all shipment line items" do
				Inventory.create(warehouse_id: wh1.id, product_id: p1.id, quantity: 1)
				Inventory.create(warehouse_id: wh2.id, product_id: p2.id, quantity: 1)
				LineItem.create(shipment_id: sh1.id, product_id: p1.id, quantity: 1)
				LineItem.create(shipment_id: sh1.id, product_id: p2.id, quantity: 1)
				d = Dispatcher.new

				expect(d.assign(sh1)).to be false
			end
		end
	end

	describe "#decrement_zip" do
		it "for zips 20000 and up it decreases by 10000" do
			d = Dispatcher.new

			expect(d.decrement_zip(90000)).to eq("80000")
			expect(d.decrement_zip(20000)).to eq("10000")
		end

		it "for zips less that 20000 it returns 00000" do
			d = Dispatcher.new

			expect(d.decrement_zip(19999)).to eq("00000")
		end
	end

	describe "#process" do
		it "decrements warehouse inventory by respective shipment amounts" do
			Inventory.create(warehouse_id: wh1.id, product_id: p1.id, quantity: 1)
			Inventory.create(warehouse_id: wh1.id, product_id: p2.id, quantity: 3)
			LineItem.create(shipment_id: sh2.id, product_id: p1.id, quantity: 1)
			LineItem.create(shipment_id: sh2.id, product_id: p2.id, quantity: 2)
			d = Dispatcher.new

			d.process(wh1.id, sh2.line_items)

			expect(Warehouse.find(wh1.id).inventory.find_by_product_id(p1.id).quantity).to eq(0)
			expect(Warehouse.find(wh1.id).inventory.find_by_product_id(p2.id).quantity).to eq(1)
		end
	end

	describe "#reallocate" do

		def manifest_compare(line_items)
			line_items.map { |li| [li.product_id, li.quantity] }
		end

		it "breaks up shipments into smaller shipments and destroys the original /
			if shipment cannot be fulfilled by one warehouse" do
			Inventory.create(warehouse_id: wh1.id, product_id: p1.id, quantity: 1)
			Inventory.create(warehouse_id: wh2.id, product_id: p2.id, quantity: 1)
			LineItem.create(shipment_id: sh1.id, product_id: p1.id, quantity: 1)
			LineItem.create(shipment_id: sh1.id, product_id: p2.id, quantity: 1)
			original_manifest = manifest_compare(sh1.line_items)
			d = Dispatcher.new

			d.reallocate(sh1)
			added_lis = Shipment.last(2).map(&:line_items).flatten
			
			expect(original_manifest).to eq(manifest_compare(added_lis))
			expect{Shipment.find(sh1.id)}.to raise_exception(ActiveRecord::RecordNotFound)
		end

		it "adds to errors if new shipment cannot be fulfilled" do
			Inventory.create(warehouse_id: wh2.id, product_id: p2.id, quantity: 1)
			not_enough = LineItem.create(shipment_id: sh1.id, product_id: p2.id, quantity: 3)
			d = Dispatcher.new

			d.reallocate(sh1)

			expect(d.errors.messages[:shipments].first).to eq("Cannot fulfill full order " +
				"of product #{not_enough.product_id} for #{not_enough.quantity} units")
		end
	end
end
