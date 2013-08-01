class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    search_args = [:all]

    # Reinstate previous sort and filter options from the session[] hash
    redirect = false
    if params.has_key? :ratings
      session[:ratings] = params[:ratings]
    elsif session.has_key? :ratings and !params.has_key? :ratings
      params[:ratings] = session[:ratings]
      redirect = true
    elsif !session.has_key? :ratings and !params.has_key? :ratings
      ratings = {}
      Movie.ratings.each do |key|
        ratings[key] = "yes"
      end
      params[:ratings] = ratings
      session[:ratings] = ratings
      redirect = true
    end
    if params.has_key? :sorted_by
      session[:sorted_by] = params[:sorted_by]
    elsif session.has_key? :sorted_by and !params.has_key? :sorted_by
      params[:sorted_by] = session[:sorted_by]
      redirect = true
    elsif !session.has_key? :ratings and !params.has_key? :ratings
      sorted_by = nil
      params[:sorted_by] = sorted_by
      session[:sorted_by] = sorted_by
      redirect = true
    end

    # If settings have been loaded from the session[] hash, reload
    # the page with the correct params[] to maintain RESTful state
    if redirect
      flash.keep
      redirect_to params
    end

    # Fetch the list of possible movie ratings
    @all_ratings = Movie.ratings

    # Check for the ratings parameter and filter the movies accordingly
    if params.has_key? :ratings
      @ratings = params[:ratings]
      search_args << {:conditions => ["rating IN (?)", @ratings.each_key]}
    end

    # Check for the sorted_by parameter and sort the movies accordingly
    if params.has_key? :sorted_by
      @sorted_by = params[:sorted_by]
      if params[:sorted_by] == "title"
        search_args << {:order => :title}
      elsif params[:sorted_by] == "release_date"
        search_args << {:order => :release_date}
      end
    else
      @sorted_by = nil
    end

    # Find all movies satisfying the given search criteria
    @movies = Movie.find(*search_args)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
