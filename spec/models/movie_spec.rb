require 'spec_helper'

describe 'Movie#correlation' do
  it 'should return 1 for identical movies' do
    a_trope = Trope.new
    a_trope.url = 'a'

    subject = Movie.new
    subject.tropes = [a_trope]

    subject.correlation(subject).should == 1
  end

  it 'should return 0 for dissimilar movies' do
    a_trope = Trope.new
    a_trope.url = 'a'
    subject = Movie.new
    subject.tropes = [a_trope]

    other_trope = Trope.new
    other_trope.url = 'b'
    other = Movie.new
    other.tropes = [other_trope]

    subject.correlation(other).should == 0
  end

  it 'should return 0.5 for movies with one of two tropes matching' do
    a_trope = Trope.new
    a_trope.url = 'a'
    shared_trope = Trope.new
    shared_trope.url = 'b'
    subject = Movie.new
    subject.tropes = [a_trope, shared_trope]

    other_trope = Trope.new
    other_trope.url = 'c'
    other = Movie.new
    other.tropes = [shared_trope, other_trope]

    subject.correlation(other).should == 0.5
  end

  it 'should return measure the number of matches out of the maximum possible matches' do
    shared_trope = Trope.new
    shared_trope.url = 'b'
    subject = Movie.new
    subject.tropes = [shared_trope]

    other_trope = Trope.new
    other_trope.url = 'c'
    other = Movie.new
    other.tropes = [shared_trope, other_trope]

    subject.correlation(other).should == 1
  end
end