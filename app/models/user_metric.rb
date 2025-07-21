class UserMetric < ApplicationRecord
  belongs_to :user

  validates :total_comments, :approved_comments, :rejected_comments,
           :approval_rate, :average_comment_length, :median_comment_length,
           :std_dev_comment_length, presence: true
end
