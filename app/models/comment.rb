class Comment < ApplicationRecord
  belongs_to :post
  has_one :user, through: :post

  validates :body, :original_body, presence: true
  validates :external_id, presence: true, uniqueness: true
end
