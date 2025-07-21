class CalculateGroupMetricsJob < ApplicationJob
  queue_as :metrics

  def perform
    Metric::GroupCalculationService.new.call
  end
end
