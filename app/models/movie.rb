class Movie < ActiveRecord::Base
  scope :by_name, :order => :name
  has_many :movie_tropes, :dependent => :destroy
  has_many :tropes, :through => :movie_tropes, :autosave => true

  validates_presence_of :name, :url
end
