require 'rails_helper'

RSpec.describe Payrolls::Create, type: :service do
  include ActiveSupport::Testing::TimeHelpers

  describe '.call' do
    context 'when no payroll exists' do
      before { travel_to(Date.new(2025, 4, 1)) }
      after  { travel_back }

      it 'creates only one payroll in the past' do
        expect(Payroll.count).to eq(0)

        described_class.call
        expect(Payroll.count).to eq(1)

        first = Payroll.first

        expect(first.starts_at).to eq(Date.new(2025, 2, 5))
        expect(first.ends_at).to   eq(Date.new(2025, 2, 19))

        described_class.call
        expect(Payroll.count).to eq(2)

        second = Payroll.last
        expect(second.starts_at).to eq(Date.new(2025, 2, 20))
        expect(second.ends_at).to   eq(Date.new(2025, 3, 4))
      end
    end

    context 'when some payrolls exist' do
      before { travel_to(Date.new(2025, 3, 10)) }
      after  { travel_back }

      it 'creates the next payroll in the chain' do

        Payroll.create!(
          starts_at: Date.new(2025,1,5),
          ends_at:   Date.new(2025,1,19)
        )

        expect(Payroll.count).to eq(1)

        described_class.call
        expect(Payroll.count).to eq(2)

        new_payroll = Payroll.order(:starts_at).last

        expect(new_payroll.starts_at).to eq(Date.new(2025,1,20))
        expect(new_payroll.ends_at).to eq(Date.new(2025,2,4))
      end
    end

    context 'when the next period would be in the future' do
      before { travel_to(Date.new(2025, 1, 10)) }
      after  { travel_back }

      it 'does not create a new payroll' do
        Payroll.create!(
          starts_at: Date.new(2025,1,5),
          ends_at:   Date.new(2025,1,31)
        )

        expect { described_class.call }.not_to change { Payroll.count }
      end
    end
  end
end
