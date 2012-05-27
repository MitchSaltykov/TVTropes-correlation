class Trope < ActiveRecord::Base
  scope :by_name, :order => :name

  has_many :movies, :through => :movie_tropes
  has_many :movie_tropes
  validates_uniqueness_of :url
end