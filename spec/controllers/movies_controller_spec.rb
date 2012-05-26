require 'spec_helper'

describe MoviesController do
  describe 'MoviesController#create' do
    let(:target_url) { 'http://tvtropes.org/movie_url' }
    #'http://tvtropes.org/pmwiki/pmwiki.php/Film/PitchBlack'

    it 'should create a movie from the specified url' do
      movie = double(:movie)
      movie.stub(:id => 1, :valid? => true)
      Movie.should_receive(:create_from_url).with(target_url).and_return(movie)

      post :create, :movie => {:url => target_url}

      response.should redirect_to movie_path(1)
    end

    it 'should fail for movies that failed to load' do
      Movie.should_receive(:create_from_url).with(target_url).and_return(false)

      post :create, :movie => {:url => target_url}

      response.should render_template :new
    end

    it 'should fail for movies that failed validation' do
      movie = double(:movie)
      movie.stub(:valid? => false)
      Movie.should_receive(:create_from_url).with(target_url).and_return(movie)

      post :create, :movie => {:url => target_url}

      response.should render_template :new
    end
  end
end
