FactoryGirl.define do
	sequence(:sku) { |n| "CAS#{n}" }
	factory :product do
		sku { generate(:sku) }
	end
end
