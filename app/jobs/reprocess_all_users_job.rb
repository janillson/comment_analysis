class ReprocessAllUsersJob
  include Sidekiq::Job

  sidekiq_options queue: :reprocessing

  def perform
    User.find_each do |user|
      # Reprocessa comentários
      user.comments.each do |comment|
        comment.update!(status: 'created', matched_keywords_count: 0)
        ProcessCommentJob.perform_async({ "comment_id" => comment.id})
      end

      # Recalcula métricas
      CalculateUserMetricsJob.perform_async({"user_id" => user.id})
    end

    CalculateGroupMetricsJob.perform_async
  end
end
