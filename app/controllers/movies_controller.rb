class MoviesController < ApplicationController
require 'nokogiri'
require 'open-uri'

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
    respond_to do |format|
      if @movie.save
        flash[:notice] = 'Movie was successfully created.'
        format.html { redirect_to @movie }
      else
        flash.now[:error] = 'Movie not created.'
        format.html { render :action => :new }
      end
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
  end
end
