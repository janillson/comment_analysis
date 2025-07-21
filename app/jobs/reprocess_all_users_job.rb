class ReprocessAllUsersJob < ApplicationJob
  queue_as :reprocessing

  def perform
    User.find_each do |user|
      # Reprocessa comentários
      user.comments.each do |comment|
        comment.update!(status: 'created', matched_keywords_count: 0)
        ProcessCommentJob.perform_later(comment.id)
      end

      # Recalcula métricas
      CalculateUserMetricsJob.perform_later(user.id)
    end

    CalculateGroupMetricsJob.perform_later
  end
end
