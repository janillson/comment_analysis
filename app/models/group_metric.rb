class GroupMetric < ApplicationRecord
  validates :total_users, :total_comments, :overall_approval_rate,
           :average_comments_per_user, :median_comments_per_user,
           :std_dev_comments_per_user, presence: true
end
