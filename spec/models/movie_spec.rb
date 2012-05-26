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

describe 'Movie#create_from_url' do
  let(:target_url) { 'http://tvtropes.org/movie_url' }
  #e.g., 'http://tvtropes.org/pmwiki/pmwiki.php/Film/PitchBlack'

  it 'should initialize a movie from the specified url' do
    movie_page = <<-PAGE_CONTENTS
          <div class='pagetitle'>
            Film:  <span>Pitch Black</span>
          </div>
          <div id='wikitext'>
            <h2><em>Pitch Black</em> contains examples of:</h2>
          </div>
    PAGE_CONTENTS

    mock_readable = stub(:read => movie_page)
    Movie.should_receive(:open).with(target_url).and_return(mock_readable)

    new_movie, empty_page = Movie.create_from_url(target_url)

    new_movie.name.should == 'Pitch Black'
    new_movie.url.should == target_url
    empty_page.should be_false
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
    Movie.should_receive(:open).with(target_url).and_return(mock_readable)

    new_movie, empty_page = Movie.create_from_url(target_url)
    new_movie.name.should == 'Pitch Black'
    new_movie.url.should == target_url
    empty_page.should be_false

    tropes = new_movie.tropes
    tropes.size.should == 2
    action_girl = tropes.first
    action_girl.name.should == 'Action Girl'
    action_girl.url.should == 'http://tvtropes.org/pmwiki/pmwiki.php/Main/ActionGirl'

    and_this_is_for = tropes.second
    and_this_is_for.name.should == 'And This Is For'
    and_this_is_for.url.should == 'http://tvtropes.org/pmwiki/pmwiki.php/Main/AndThisIsFor'
  end

  it 'should log tropes nested in folders' do
    movie_page = <<-PAGE_CONTENTS
          <div class='pagetitle'>
            Film:  <span>Alien</span>
          </div>
          <div id='wikitext'>
            <h2><em>Alien</em> contains examples of:</h2>

            <div class='folder'>
              <ul>
                <li>
                    <a class='twikilink' href='http://tvtropes.org/pmwiki/pmwiki.php/Main/ActionGirl' title='http://tvtropes.org/pmwiki/pmwiki.php/Main/ActionGirl'>Action Girl</a>
                </li>
              </ul>
            </div>
          </div>
    PAGE_CONTENTS

    mock_readable = stub(:read => movie_page)
    Movie.should_receive(:open).with(target_url).and_return(mock_readable)

    created_movie, empty_page = Movie.create_from_url(target_url)
    created_movie.name.should == 'Alien'
    created_movie.url.should == target_url
    empty_page.should be_false

    tropes = created_movie.tropes
    tropes.size.should == 1
    action_girl = tropes.first
    action_girl.name.should == 'Action Girl'
    action_girl.url.should == 'http://tvtropes.org/pmwiki/pmwiki.php/Main/ActionGirl'
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
    Movie.should_receive(:open).with(target_url).and_return(mock_readable)

    new_movie, empty_page = Movie.create_from_url(target_url)
    empty_page.should be_true
  end
end