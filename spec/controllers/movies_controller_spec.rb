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

    it 'should log tropes for a specified movie' do
      movie_page = <<-PAGE_CONTENTS
        <div class='pagetitle'>
          Film:  <span>Pitch Black</span>
        </div>
        <div id='wikitext'>
          <h2><em>Pitch Black</em> contains examples of:</h2>
          <ul>
              <li>
                  <a class='twikilink' href='http://tvtropes.org/pmwiki/pmwiki.php/Main/ActionGirl' title='http://tvtropes.org/pmwiki/pmwiki.php/Main/ActionGirl'>Action Girl</a>: Carolyn Fry
              </li>
              <li>
                  <a class='twikilink' href='http://tvtropes.org/pmwiki/pmwiki.php/Main/AndThisIsFor' title='http://tvtropes.org/pmwiki/pmwiki.php/Main/AndThisIsFor'>And This Is for...</a>: Riddick cuts off all the lights on the ship prior to taking off, because he wants to
                  kill as many of the creatures as possible when they gather around the ship. It's implied it's in honor of
                  Fry.
                  <div class='indent'><strong>Riddick:</strong> We can't leave...
                      <em>(<a class='twikilink' href='http://tvtropes.org/pmwiki/pmwiki.php/Main/Beat' title='http://tvtropes.org/pmwiki/pmwiki.php/Main/Beat'>beat</a>)</em>
                      without saying good night. <strong>(FWOOSH)</strong></div>
              </li>
          </ul>
        </div>
      PAGE_CONTENTS

      mock_readable = stub(:read => movie_page)
      controller.should_receive(:open).and_return(mock_readable)

      post :create, :movie => {:url => target_url}

      created_movie = Movie.first
      created_movie.name.should == 'Pitch Black'
      created_movie.url.should == target_url

      tropes = created_movie.tropes
      tropes.size.should == 2
      action_girl = tropes.first
      action_girl.name.should == 'Action Girl'
      action_girl.url.should == 'http://tvtropes.org/pmwiki/pmwiki.php/Main/ActionGirl'

      and_this_is_for = tropes.second
      and_this_is_for.name.should == 'And This Is For'
      and_this_is_for.url.should == 'http://tvtropes.org/pmwiki/pmwiki.php/Main/AndThisIsFor'
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
