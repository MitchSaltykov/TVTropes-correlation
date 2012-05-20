class MoviesController < ApplicationController
  require 'nokogiri'
  require 'open-uri'

  EMPTY_PAGE_TEXT = 'Click the edit button to start this new page.'

  def index
    @movies = Movie.by_name
  end

  def show
    @movie = Movie.find(params[:id])

    similar_movies = {}
    (Movie.all - [@movie]).each do |other_movie|
      movie_correlation = @movie.correlation(other_movie)
      similar_movies[other_movie] = movie_correlation unless movie_correlation == 0
    end
    @most_similar_movies = similar_movies.sort_by {|_,correlation| correlation}.last(5).reverse
  end

  def new
    @movie = Movie.new
  end

  def create
    url = params[:movie][:url]
    page = Nokogiri::HTML(open(url))
    name = page.search('.pagetitle span').first.content
    @movie = Movie.new
    @movie.name = name
    @movie.url = url
    wikitext = page.search('#wikitext')
    empty_page = wikitext && wikitext.children.first.text.strip == EMPTY_PAGE_TEXT

    trope_urls = page.css('div#wikitext > ul > li > a.twikilink').map { |link| link['href'] }.uniq
    tropes = trope_urls.map do |trope_url|
      trope = Trope.find_or_initialize_by_url(trope_url)
      trope.name = trope_url.split('/').last.underscore.titleize

      trope
    end
    @movie.tropes = tropes.sort_by(&:name)

    respond_to do |format|
      if !empty_page && @movie.save
        flash[:notice] = 'Movie was successfully created.'
        format.html { redirect_to @movie }
      else
        flash.now[:error] = "Movie not created. #{'Page has no content' if empty_page}"
        format.html { render :action => :new }
      end
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy

    redirect_to :action => :index
  end
end
