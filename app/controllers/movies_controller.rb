class MoviesController < ApplicationController
  require 'nokogiri'
  require 'open-uri'

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
    @most_similar_movies = similar_movies.sort_by { |_, correlation| correlation }.last(5).reverse
  end

  def new
    @movie = Movie.new
  end

  def create
    respond_to do |format|
      @movie, empty_page = Movie.create_from_url(params[:movie][:url])
      if @movie && @movie.valid? && !empty_page
        flash[:notice] = 'Movie was successfully created.'
        format.html { redirect_to :action => :show, :id => @movie.id }
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
