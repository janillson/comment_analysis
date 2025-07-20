class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, through: :posts

  validates :username, presence: true, uniqueness: true
  validates :external_id, presence: true, uniqueness: true
end
