# frozen_string_literal: true

class Genre < ApplicationRecord
  has_many :authors, dependent: :destroy
  has_many :book_editions, dependent: :destroy
end
