# app/jobs/payrolls_generation_job.rb

class PayrollsCreationJob < ApplicationJob
  queue_as :default

  def perform
    Payrolls::Create.call
  end
end
