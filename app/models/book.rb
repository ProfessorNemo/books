# frozen_string_literal: true

class Book < ApplicationRecord
  include BlockOne
  include BlockTwo
  include BlockThree

  validates :title, presence: true, uniqueness: true, length: { minimum: 1, maximum: 255 }
  validates :author, presence: true, length: { minimum: 3, maximum: 50 }
  validates :price,
            numericality: { greater_than_or_equal_to: 0 }
  validates :amount,
            numericality: { greater_than_or_equal_to: 0 }
end
