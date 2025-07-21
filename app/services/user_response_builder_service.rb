class UserResponseBuilderService
  def initialize(user)
    @user = user
  end

  def call
    return if @user.nil?
    ensure_user_metrics_calculated
    ensure_group_metrics_calculated

    {
      user: {
        username: @user.username,
        name: @user.name,
        email: @user.email
      },
      user_metrics: format_user_metrics,
      group_metrics: format_group_metrics
    }
  end

  private

  def ensure_user_metrics_calculated
    if @user.user_metric.nil?
      Metric::UserCalculationService.new(@user).call
      @user.reload
    end
  end

  def ensure_group_metrics_calculated
    if GroupMetric.first.nil?
      Metric::GroupCalculationService.new.call
    end
  end

  def format_user_metrics
    metrics = @user.user_metric

    return {} if metrics.nil?

    {
      total_comments: metrics.total_comments || 0,
      approved_comments: metrics.approved_comments || 0,
      rejected_comments: metrics.rejected_comments || 0,
      approval_rate: format_percentage(metrics.approval_rate),
      average_comment_length: format_decimal(metrics.average_comment_length),
      median_comment_length: format_decimal(metrics.median_comment_length),
      std_dev_comment_length: format_decimal(metrics.std_dev_comment_length)
    }
  end

  def format_group_metrics
    metrics = GroupMetric.first

    return {} if metrics.nil?

    {
      total_users: metrics.total_users || 0,
      total_comments: metrics.total_comments || 0,
      overall_approval_rate: format_percentage(metrics.overall_approval_rate),
      average_comments_per_user: format_decimal(metrics.average_comments_per_user),
      median_comments_per_user: format_decimal(metrics.median_comments_per_user),
      std_dev_comments_per_user: format_decimal(metrics.std_dev_comments_per_user)
    }
  end

  def format_percentage(value)
    return 0.0 if value.nil?

    value.to_f.round(2)
  end

  def format_decimal(value)
    return 0.0 if value.nil?

    value.to_f.round(2)
  end
end
