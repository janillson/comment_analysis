class CalculateGroupMetricsJob
  include Sidekiq::Job

  sidekiq_options queue: :metrics

  def perform
    Metric::GroupCalculationService.new.call
  end
end
