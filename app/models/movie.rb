class Movie < ActiveRecord::Base
  scope :by_name, :order => :name
  has_many :movie_tropes, :dependent => :destroy
  has_many :tropes, :through => :movie_tropes, :autosave => true

  validates_presence_of :name, :url

  def correlation(other)
    (tropes & other.tropes).size.to_f / [tropes.size, other.tropes.size].min
  end
end
