class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_one :user_metric, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :external_id, presence: true, uniqueness: true
end