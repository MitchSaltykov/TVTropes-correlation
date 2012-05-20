class MovieTrope < ActiveRecord::Base
  belongs_to :movie
  belongs_to :trope
end
