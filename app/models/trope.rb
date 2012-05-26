class Trope < ActiveRecord::Base
  has_many :movies, :through => :movie_tropes
  has_many :movie_tropes
  validates_uniqueness_of :url
end