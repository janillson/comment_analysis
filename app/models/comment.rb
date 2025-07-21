class Comment < ApplicationRecord
  include AASM

  belongs_to :post
  has_one :user, through: :post

  validates :body, :original_body, presence: true
  validates :external_id, presence: true, uniqueness: true

  aasm column: :status do
    state :created, initial: true
    state :processing
    state :approved
    state :rejected

    event :process do
      transitions from: :created, to: :processing
    end

    event :approve do
      transitions from: :processing, to: :approved
    end

    event :reject do
      transitions from: :processing, to: :reject
    end
  end
end
