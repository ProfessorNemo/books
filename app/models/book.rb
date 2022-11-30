# frozen_string_literal: true

class Book < ApplicationRecord
  include One::BlockOne
  include One::BlockTwo
  include One::BlockThree
end
