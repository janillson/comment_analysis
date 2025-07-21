class Keyword < ApplicationRecord
  validates :word, presence: true, uniqueness: { case_sensitive: false }

  before_validation { self.word = word.strip if word.present? }
  after_save :trigger_reprocessing
  after_destroy :trigger_reprocessing

  private

  def trigger_reprocessing
    ReprocessAllUsersJob.perform_later
  end
end
