FactoryGirl.define do
	factory :shipment do
		zip { Faker::Address.zip }
	end
end