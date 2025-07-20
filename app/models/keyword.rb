class Keyword < ApplicationRecord
  validates :word, presence: true, uniqueness: { case_sensitive: false }
end
