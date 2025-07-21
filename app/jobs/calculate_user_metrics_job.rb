class CalculateUserMetricsJob < ApplicationJob
  queue_as :metrics

  def perform(user_id)
    user = User.find(user_id)
    Metric::UserCalculationService.new(user).call
  end
end
