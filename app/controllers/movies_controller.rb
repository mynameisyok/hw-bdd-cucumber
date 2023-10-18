# Tmdb::Api.key('30ec578b186f5566f29d6df083bd2454')
Tmdb::Api.key(ENV['APIKEY_TMDB'])
Tmdb::Api.language("en")

class MoviesController < ApplicationController
  before_action :force_index_redirect, only: [:index]

  # def search_tmdb
  #   # Check if the title parameter is present
  #   if params[:search_terms].present?
  #     # Search for movies with the provided title
  #     search_results = Tmdb::Movie.find(params[:search_terms])
  
  #     if search_results.any?
  #       # Take the first movie from the search results
  #       movie = search_results.first
  
  #       # Assign movie details to instance variables
  #       @title = movie.title
  #       @rating = movie.vote_average.to_s
  #       @release_date = Date.parse(movie.release_date)
  #       @description = movie.overview
  #     else
  #       # Movie not found, sad path
  #       flash[:error] = "'#{params[:search_terms]}' was not found in TMDb."
  #       redirect_to movies_path
  #     end
  #   else
  #     flash[:error] = "Please provide a movie title."
  #     redirect_to movies_path
  #   end
  # end

  def search_tmdb
    # Check if the title parameter is present
    if params[:search_terms].present?
      # Search for movies with the provided title
      search_results = Tmdb::Movie.find(params[:search_terms])
  
      if search_results.any?
        # Take the first movie from the search results
        movie = search_results.first
  
        # Assign movie details to instance variables
        @title = movie.title
        @rating = movie.vote_average.to_s
        @release_date = Date.parse(movie.release_date)
        @description = movie.overview

        # เปลี่ยนทางไปที่หน้า /movies/search_tmdb
        render 'search_tmdb'
      else
        # Movie not found, sad path
        flash[:error] = "'#{params[:search_terms]}' was not found in TMDb."
        redirect_to movies_path
      end
    else
      flash[:error] = "Please provide a movie title."
      redirect_to movies_path
    end
  end
  
  


  # def search_tmdb
  #   @movie_name = params[:movie][:title]
  #   find_movie = Tmdb::Movie.find(@movie_name)
  #   if !find_movie.empty?
  #     # if Movie.find_by(name: @movie_name)
  #     # movie = find_movie[0]
  #     # @name = movie.title
  #     # @date = movie.release_date
  #     # redirect_to new_movie_path(name:@name,date:@date) 
  #     # end
  #     @movie = @movies.first
  #     redirect_to movie_path(@movie)
  #   else
  #     flash[:notice] = "'#{params[:movie][:title]}' was found in TMDb."
  #     redirect_to root_path
  #   end
  # end
  
  # def search_tmdb
  #   @movie_name = params[:movie][:title]
  #   @movies = Movie.where("title LIKE ?", "%#{@movie_name}%")
    
  #   if @movies.present?
  #     # หากพบข้อมูล
  #     @movie = @movies.first
  #     redirect_to movie_path(@movie)
  #   else
  #     # หากไม่พบข้อมูล
  #     flash[:notice] = " '#{@movie_name}' was not found in the database."
  #     redirect_to movies_path
  #   end
  # end

  # def search_tmdb
  #   Tmdb::Search.movie(params[:search_terms])

  #   # Check if the title parameter is present
  #   if params[:search_terms].present?
  #     # Search for movies with the provided title
  #     search_results = Tmdb::Search.movie(params[:search_terms])

  #     if search_results.any?
  #       # Take the first movie from the search results
  #       movie = search_results.first

  #       # Assign movie details to instance variables
  #       @title = movie.title
  #       @rating = movie.vote_average.to_s
  #       @release_date = Date.parse(movie.release_date)
  #       @description = movie.overview
  #     else
  #       # Movie not found, sad path
  #       flash[:error] = "'#{params[:search_terms]}' was not found in TMDb."
  #       redirect_to movies_path
  #     end
  #   else
  #     flash[:error] = "Please provide a movie title."
  #     redirect_to movies_path
  #   end
  # end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @movies = Movie.with_ratings(ratings_list, sort_by)
    @ratings_to_show_hash = ratings_hash
    @sort_by = sort_by
    # remember the correct settings for next time
    session['ratings'] = ratings_list
    session['sort_by'] = @sort_by
  end
  # def set_ratings
  #   @all_ratings = Movie.all_ratings
  # end

  # def index
  #   set_ratings
  #   @search_term = params[:search_term]
  #   if @search_term.present?
  #     @movies = Movie.where("title LIKE ?", "%#{@search_term}%")
  #   else
  #     @movies = Movie.all
  #   end
  # end

  def new
    if params[:movie]
      @movie = Movie.new(movie_params)
    end
    # # default: render 'new' template
    # @movie_title = params[:name]
    # @movie_rate = params[:rate] 
    # @movie_date = params[:date] || Date.today.strftime()
  end

  def create
    release_date = DateTime.new(params[:movie]["release_date(1i)"].to_i, params[:movie]["release_date(2i)"].to_i, params[:movie]["release_date(3i)"].to_i)
    
    existing_movie = Movie.find_by(title: params[:movie][:title], release_date: release_date)
    
    if existing_movie
      flash[:warning] = "Movie '#{existing_movie.title}' with the same name and release date already exists."
      redirect_to movies_path and return
    end
  
    @movie = Movie.new(movie_params.merge(release_date: release_date))
  
    if @movie.save
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    else
      render 'new'
    end
  end
  
  

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private

  def force_index_redirect
    if !params.key?(:ratings) || !params.key?(:sort_by)
      flash.keep
      url = movies_path(sort_by: sort_by, ratings: ratings_hash)
      redirect_to url
    end
  end

  def ratings_list
    params[:ratings]&.keys || session[:ratings] || Movie.all_ratings
  end

  def ratings_hash
    Hash[ratings_list.collect { |item| [item, "1"] }]
  end

  def sort_by
    params[:sort_by] || session[:sort_by] || 'id'
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end