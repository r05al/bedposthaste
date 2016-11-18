FactoryGirl.define do
	factory :warehouse do
		name { Faker::Address.city }
		zip { Faker::Address.zip }
	end
end