# frozen_string_literal: true

module Payrolls
  class Create
    def self.call
      new.call
    end

    def call
      start_date = define_start_date
      return unless start_date

      start_d, end_d = next_period(start_date)

      return if end_d > today

      Payroll.create!(starts_at: start_d, ends_at: end_d)
    end

    private

    def define_start_date

      return start_date_for_empty_db unless last_payroll

      last_payroll.ends_at + 1.day
    end

    def start_date_for_empty_db
      date = 2.months.ago.to_date
      date.day <= 19 ? date.change(day: 5) : date.change(day: 20)
    end

    def next_period(current_start)
      return period_5_to_19(current_start) if within_5_to_19?(current_start)
      period_20_to_4(current_start)
    end

    def period_5_to_19(date)
      start_d = date.day < 5 ? date.change(day: 5) : date
      end_d   = date.change(day: 19)
      [start_d, end_d]
    end

    def period_20_to_4(date)
      start_d = date.day < 20 ? date.change(day: 20) : date
      end_d   = date.next_month.change(day: 4)
      [start_d, end_d]
    end

    def today
      Date.current
    end

    def within_5_to_19?(date)
      date.day <= 19
    end

    def last_payroll
      @last_payroll ||= Payroll.order(ends_at: :desc).first
    end
  end
end
