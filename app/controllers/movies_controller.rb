class MoviesController < ApplicationController
require 'nokogiri'
require 'open-uri'

EMPTY_PAGE_TEXT = 'Click the edit button to start this new page.'

  def index
    @movies = Movie.by_name
  end

  def show
    @movie = Movie.find(params[:id])
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
  end
end
