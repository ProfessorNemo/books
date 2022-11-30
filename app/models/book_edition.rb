# frozen_string_literal: true

class BookEdition < ApplicationRecord
  include Two::Edition
  include Two::UpdateBlock
  belongs_to :genre
  belongs_to :author
end
