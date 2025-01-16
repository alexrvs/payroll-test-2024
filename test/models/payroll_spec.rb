# spec/models/payroll_spec.rb
require 'rails_helper'

RSpec.describe Payroll, type: :model do
  describe "Payroll generation rules" do
    context "when no payroll exists" do
      it "creates a payroll starting exactly 2 months ago" do
        travel_to(Date.new(2025, 5, 15)) do

          expect(Payroll.count).to eq(0)

          # Payrolls::Create.call

          expect(Payroll.count).to eq(1)

          new_payroll = Payroll.last

          expect(new_payroll.starts_at).to eq(Date.new(2025, 3, 15))
          expect(new_payroll.ends_at).to be <= Date.current
        end
      end
    end

    context "when the next payroll would be in the future" do
      it "does NOT create a new payroll" do
        travel_to(Date.new(2025, 1, 1)) do
          Payroll.create!(
            starts_at: Date.new(2024, 12, 20),
            ends_at:   Date.new(2025, 1, 2)
          )
          expect(Payroll.count).to eq(1)

          # Payrolls::Create.call

          expect(Payroll.count).to eq(1)
        end
      end
    end

    context "when a payroll already exists" do
      it "creates the next payroll immediately after the last one, no gaps" do
        travel_to(Date.new(2025, 5, 15)) do

          Payroll.create!(
            starts_at: Date.new(2025, 5, 1),
            ends_at:   Date.new(2025, 5, 10)
          )
          expect(Payroll.count).to eq(1)

          # Payrolls::Create.call

          expect(Payroll.count).to eq(2)
          new_payroll = Payroll.order(:starts_at).last

          expect(new_payroll.starts_at).to eq(Date.new(2025, 5, 11))

          expect(new_payroll.ends_at).to be <= Date.current
        end
      end
    end
  end
end
