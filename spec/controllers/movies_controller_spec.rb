require 'spec_helper'

describe MoviesController do
  describe 'MoviesController#create' do
    let(:target_url) { 'http://tvtropes.org/pmwiki/pmwiki.php/Film/PitchBlack' }
    it 'should create a movie from the specified url' do
      page = <<-PAGE_CONTENTS
        <div class='pagetitle'>
          Film:  <span>Pitch Black</span>
        </div>
      PAGE_CONTENTS

      mock_readable = stub(:read => page)
      MoviesController.stub(:open).and_yield(mock_readable)

      post :create, :movie => {:url => target_url}

      created_movie = Movie.first
      created_movie.name.should == 'Pitch Black'
      created_movie.url.should == target_url
    end
  end
end
