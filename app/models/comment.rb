class Comment < ApplicationRecord
  include AASM

  belongs_to :post
  belongs_to :user

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
      transitions from: :processing, to: :rejected
    end
  end
end
