require 'rails_helper'

RSpec.describe Warehouse, type: :model do

	it "has a valid factory" do
	  expect(build(:warehouse)).to be_valid
	end

	describe "name" do
		it { should validate_presence_of(:name) }
		it { should validate_uniqueness_of(:name) }
	end

	describe "zip" do
		it { should validate_presence_of(:zip) }
	end

	describe "associations" do
		it { should have_many(:products).through(:inventory)}
		it { should have_many(:inventory)}
	end

end
