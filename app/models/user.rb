class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true
  validates :external_id, presence: true, uniqueness: true
end
