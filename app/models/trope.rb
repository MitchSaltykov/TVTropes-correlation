class Trope < ActiveRecord::Base
  has_many :movies
  validates_uniqueness_of :url
end