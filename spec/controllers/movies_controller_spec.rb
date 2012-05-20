require 'spec_helper'

describe MoviesController do
  describe 'MoviesController#create' do
    let(:target_url) { 'http://tvtropes.org/movie_url' }
    #'http://tvtropes.org/pmwiki/pmwiki.php/Film/PitchBlack'

    it 'should create a movie from the specified url' do
      movie_page = <<-PAGE_CONTENTS
        <div class='pagetitle'>
          Film:  <span>Pitch Black</span>
        </div>
        <div id='wikitext'>
          <h2><em>Pitch Black</em> contains examples of:</h2>
        </div>

      PAGE_CONTENTS

      mock_readable = stub(:read => movie_page)
      controller.should_receive(:open).and_return(mock_readable)

      post :create, :movie => {:url => target_url}

      created_movie = Movie.first
      created_movie.name.should == 'Pitch Black'
      created_movie.url.should == target_url
    end

    it 'should reject movies with no page content' do
      new_entry_page = <<-PAGE_CONTENTS
        <div class='pagetitle'>
          Film:  <span>Pitch Blackasdf</span>
        </div>
        <div id='wikitext'>
          Click the edit button to start this new page.
        </div>
      PAGE_CONTENTS

      mock_readable = stub(:read => new_entry_page)
      controller.should_receive(:open).and_return(mock_readable)

      post :create, :movie => {:url => target_url}

      Movie.count.should == 0
    end
  end
end
