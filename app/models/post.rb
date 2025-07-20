class Post < ApplicationRecord
  belongs_to :user

  validates :title, :body, presence: true
  validates :external_id, presence: true, uniqueness: true
end
