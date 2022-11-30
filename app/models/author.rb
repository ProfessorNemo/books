# frozen_string_literal: true

class Author < ApplicationRecord
  has_many :genres, dependent: :destroy
  has_many :book_editions, dependent: :destroy
end
