# lib/tasks/payrolls.rake

namespace :payrolls do
  desc "Generate missing payrolls (calls ActiveJob)"
  task auto_create: :environment do
    PayrollsCreationJob.perform_now
  end
end
