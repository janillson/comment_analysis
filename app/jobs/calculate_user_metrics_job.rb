class CalculateUserMetricsJob
  include Sidekiq::Job

  sidekiq_options queue: :metrics

  def perform(args)
    user_id = args["user_id"]

    user = User.find(user_id)
    Metric::UserCalculationService.new(user).call
  end
end
