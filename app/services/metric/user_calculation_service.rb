module Metric
  class UserCalculationService
    def initialize(user)
      @user = user
    end

    def call
      comments = @user.comments.where.not(status: 'created')

      return if comments.empty?

      comment_lengths = comments.map { |c| c.body.length }

      metrics = {
        total_comments: comments.count,
        approved_comments: comments.approved.count,
        rejected_comments: comments.rejected.count,
        approval_rate: calculate_approval_rate(comments),
        average_comment_length: comment_lengths.sum.to_f / comment_lengths.size,
        median_comment_length: calculate_median(comment_lengths),
        std_dev_comment_length: calculate_std_dev(comment_lengths)
      }

      @user.build_user_metric(metrics) if @user.user_metric.nil?
      @user.user_metric.update(metrics)

      Rails.cache.write("user_analysis_#{@user.username}", UserResponseBuilderService.new(@user).call)
    end

    private

    def calculate_approval_rate(comments)
      return 0.0 if comments.empty?

      (comments.approved.count.to_f / comments.count * 100).round(2)
    end

    def calculate_median(array)
      sorted = array.sort
      len = sorted.length

      if len.odd?
        sorted[len / 2]
      else
        (sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0
      end
    end

    def calculate_std_dev(array)
      mean = array.sum.to_f / array.length
      variance = array.map { |x| (x - mean) ** 2 }.sum / array.length
      Math.sqrt(variance).round(2)
    end
  end
end
