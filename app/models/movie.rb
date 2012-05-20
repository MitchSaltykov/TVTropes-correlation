class Movie < ActiveRecord::Base
  scope :by_name, :order => :name

  validates_presence_of :name, :url
end
