module Metric
  class GroupCalculationService
    def call
      users = User.joins(:comments).where.not(comments: { status: 'created' }).distinct

      return if users.empty?

      comments = Comment.where.not(status: 'created').where(user: users)

      comments_per_user = users.map { |user| user.comments.where.not(status: 'created').count }

      metrics = {
        total_users: users.count,
        total_comments: comments.count,
        overall_approval_rate: calculate_overall_approval_rate(comments),
        average_comments_per_user: calculate_average_comments_per_user(comments_per_user),
        median_comments_per_user: calculate_median(comments_per_user),
        std_dev_comments_per_user: calculate_std_dev(comments_per_user)
      }

      group_metric = GroupMetric.first_or_initialize
      group_metric.update!(metrics)

      users.each { |user| Rails.cache.write("user_analysis_#{user.username}", UserResponseBuilderService.new(user).call) }
    end

    private

    def calculate_overall_approval_rate(all_comments)
      return 0.0 if all_comments.empty?

      approved_count = all_comments.where(status: 'approved').count
      (approved_count.to_f / all_comments.count * 100).round(2)
    end

    def calculate_average_comments_per_user(comments_per_user_array)
      return 0.0 if comments_per_user_array.empty?

      (comments_per_user_array.sum.to_f / comments_per_user_array.size).round(2)
    end

    def calculate_median(array)
      return 0.0 if array.empty?

      sorted = array.sort
      len = sorted.length

      if len.odd?
        sorted[len / 2].to_f
      else
        (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
      end
    end

    def calculate_std_dev(array)
      return 0.0 if array.empty?

      mean = array.sum.to_f / array.length
      variance = array.map { |x| (x - mean) ** 2 }.sum / array.length
      Math.sqrt(variance).round(2)
    end
  end
end
