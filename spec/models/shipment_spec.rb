require 'rails_helper'

RSpec.describe Shipment, type: :model do
	describe "zip" do
		it { should validate_presence_of(:zip) }
	end

	describe "associations" do
		it { should have_many(:products).through(:line_items)}
		it { should have_many(:line_items)}
	end
end
