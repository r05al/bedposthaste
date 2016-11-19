class Dispatcher
	include ActiveModel::Model

	attr_reader :shipments, :warehouses

	def initialize
		@shipments = Shipment.joins(:line_items).where(warehouse_id: nil)
		@warehouses = Warehouse.order(:zip).includes(:inventory) #ordered by zip
	end

	def allocate(shipments) #only with lis
		shipments.each do |shipment|
			unless assign(shipment)
				reallocate(shipment)
			end
		end
	end

	def assign(shipment)
		zip = shipment.zip[0] + "0000"
		line_items = shipment.line_items
		potential_wh = warehouses.dup
		while potential_wh.size > 0 do
			nearest = []
			up_closest_wh = potential_wh.bsearch do |wh|
				wh.zip >= zip
			end
			down_closest_wh = potential_wh.bsearch do |wh|
				wh.zip >= decrement_zip(zip)
			end
			up_closest_wh ? nearest.push(up_closest_wh) : zip = decrement_zip(zip)
			down_closest_wh ? nearest.push(down_closest_wh) : zip = decrement_zip(zip) 
			nearest.each do |wh|
				inventory_matched = 0
				line_items.each do |li|
					inv = wh.inventory.find_by_product_id(li.product_id)
					if inv && inv.quantity >= li.quantity
						inventory_matched += 1
					else
						inventory_matched = -1
						break
					end
				end
				if inventory_matched == line_items.length
					shipment.update(warehouse_id: wh.id)
					process(wh.id, line_items)
					return true
				else
					potential_wh = potential_wh - [wh] #AR Relation
				end
			end
		end
		return false
	end

	def process(warehouse_id, line_items)
		line_items.each do |li|
			inv = Inventory.find_by_warehouse_id_and_product_id(warehouse_id, li.product_id)
			new_qty = inv.quantity - li.quantity
			inv.update(quantity: new_qty)
		end
	end

	def decrement_zip(zip)
		d_zip = zip.to_i
		if d_zip < 20000
			return "00000"
		else
			d_zip -= 10000
			return d_zip.to_s
		end
	end

	def reallocate(shipment)
		#for simplicity break up each line item into own shipment
		shipment.line_items.each do |li|
			s = Shipment.create(zip: shipment.zip)
			LineItem.create(shipment_id: s.id, product_id: li.product_id, quantity: li.quantity)
			unless assign(s)
				li = s.line_items.first
				errors.add(:shipments, :inventory, message: "Cannot fulfill full order of product " +
					"#{li.product_id} for #{li.quantity} units")
			end
		end
		shipment.destroy
	end

	def partial(shipment)
		li = shipment.line_items.first
		units_needed = li.quantity
		product_locations = Inventory.where(product_id: li.product_id).order(:quantity).reverse_order
		product_locations.each do |pl|
			s = Shipment.create(zip: shipment.zip, warehouse_id: pl.warehouse_id)
			if units_needed > pl.quantity
				units_needed -= pl.quantity
				s.line_items.create(product_id: li.product_id, quantity: pl.quantity)
				pl.update(quantity: 0)
			else
				remaining_inv = pl.quantity - units_needed
				s.line_items.create(product_id: li.product_id, quantity: units_needed)
				pl.update(quantity: remaining_inv)
				return true
			end
		end
		remainder = Shipment.create(zip: shipment.zip)
		remainder.line_items.create(product_id: li.product_id, quantity: units_needed)
		return false
	end

end