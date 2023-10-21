Tmdb::Api.key(ENV['APIKEY_TMDB'])
Tmdb::Api.language("en")
require 'httparty'
require 'json'
require 'net/http'

class MoviesController < ApplicationController
  before_action :force_index_redirect, only: [:index]
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'
  API_KEY = ENV['APIKEY_TMDB']

  def search_tmdb
    # Check if the title parameter is present
    if params[:search_terms].present?
      # Search for movies with the provided title
      search_results = Tmdb::Movie.find(params[:search_terms])
      if search_results.any?
        # Take the first movie from the search results
        @movie_name = search_results.first
        # Assign movie details to instance variables
        @title = @movie_name.title
        @release_date = Date.parse(@movie_name.release_date)
        @description = @movie_name.overview
        # เรียก API เพื่อดึงรูปภาพ
        # ทำ HTTP request เพื่อเรียกใช้ API ของ TMDb
        movie_id = @movie_name.id
        # response = HTTParty.get("https://api.themoviedb.org/3/movie/#{movie_id}/images", query: { api_key: ENV['APIKEY_TMDB'] })
        # # Get the image URL from the response
        # # @image_url = "https://image.tmdb.org/t/p/original#{response.parsed_response['backdrops'].first['file_path']}"
        # backdrops = response.parsed_response['backdrops']
        # if backdrops.present? && backdrops.first.present? && backdrops.first['file_path'].present?
        #   @image_url = "https://image.tmdb.org/t/p/original#{backdrops.first['file_path']}"
          
        # else
        #   @image_url = ""
        # end
        # ดึงข้อมูลเรทติ้ง
        mpaa_rating = fetch_mpaa_rating(movie_id)
        @rating = mpaa_rating || "Not Rated"
        # เปลี่ยนทางไปที่หน้า /movies/search_tmdb

        # ดึง ID ของหนังจาก API ของ TMDb
        @tmdb_id = @movie_name.id
        # ดึง URL ของรูปภาพจาก API ของ TMDb
        @image_url = fetch_movie_images(@tmdb_id)
        render 'search_tmdb'
      else
        @movie_name = params[:search_terms]
        @find_movies = Movie.where("title LIKE ?", "%#{@movie_name}%")

        if @find_movies.present?
          # หากพบข้อมูลในฐานข้อมูล
          flash[:warning] = "'#{params[:search_terms]}' was not found in TMDb but found in database."
          @movie = @find_movies.first
          redirect_to movie_path(@movie)
        else
          # หากไม่พบข้อมูลทั้งใน TMDb และ ฐานข้อมูล
          flash[:warning] = "'#{params[:search_terms]}' was not found in the TMDb and database."
          render 'new'
        end
      end
    else
      flash[:warning] = "Please provide a movie title."
      redirect_to movies_path
    end
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # @all_ratings = Movie.to_s.all_ratings
    @all_ratings = Movie.all_ratings.map(&:to_s)
    puts @all_ratings
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

  def fetch_movie_images(movie_id)
    response = HTTParty.get("https://api.themoviedb.org/3/movie/#{movie_id}/images", query: { api_key: ENV['APIKEY_TMDB'] })
    backdrops = response.parsed_response['backdrops']
    if backdrops.present? && backdrops.first.present? && backdrops.first['file_path'].present?
      image_url = "https://image.tmdb.org/t/p/original#{backdrops.first['file_path']}"
      return image_url
    else
      return nil
    end
  end
  
  def create
    release_date = DateTime.new(params[:movie]["release_date(1i)"].to_i, params[:movie]["release_date(2i)"].to_i, params[:movie]["release_date(3i)"].to_i)
    existing_movie = Movie.find_by(title: params[:movie][:title], release_date: release_date)
    
    if existing_movie
      flash[:warning] = "Movie '#{existing_movie.title}' with the same name and release date already exists."
      redirect_to movies_path and return
    end
  
    @movie = Movie.new(movie_params.merge(release_date: release_date))
    search_results = Tmdb::Movie.find(@movie.title)

    if search_results.any?
    
      @movie_name = search_results.first
      @tmdb_id = @movie_name.id
      @image_url = fetch_movie_images(@tmdb_id)

      # กำหนดค่า image_url ในฐานข้อมูล
      @movie.image = @image_url

      # Save the movie object after attaching the image
      if @movie.save
        flash[:notice] = "#{@movie.title} was successfully created."
        redirect_to movies_path
      else
        render 'new'
      end
    end
  end

  # def create
  #   release_date = DateTime.new(params[:movie]["release_date(1i)"].to_i, params[:movie]["release_date(2i)"].to_i, params[:movie]["release_date(3i)"].to_i)
    
  #   existing_movie = Movie.find_by(title: params[:movie][:title], release_date: release_date)
    
  #   if existing_movie
  #     flash[:warning] = "Movie '#{existing_movie.title}' with the same name and release date already exists."
  #     redirect_to movies_path and return
  #   end

  #   @movie = Movie.new(movie_params.merge(release_date: release_date))
  #   search_results = Tmdb::Movie.find(@movie.title)
    
  #   if search_results.any?
  #     @movie_name = search_results.first
  #     @tmdb_id = @movie_name.id
  #     @image_url = fetch_movie_images(@tmdb_id)
  
  #     # Download and attach the image to the movie
  #     uri = URI.parse(@image_url)
  #     http = Net::HTTP.new(uri.host, uri.port)
  #     http.use_ssl = (uri.scheme == 'https')
  #     response = http.request(Net::HTTP::Get.new(uri.request_uri))
  #     puts 'yookkkk'
  #     puts @image_url
  #     puts 'yookkkk'
  #     if response.code.to_i == 200
  #       @movie.image.attach(io: StringIO.new(response.body), filename: "image.jpg", content_type: "image/jpg")
        
  #       respond_to do |format|
  #         if @movie.save
  #           format.html { redirect_to movies_path(format: :html), notice: "#{@movie.title} was successfully created." }
  #           format.json { render json: @movie, status: :created, location: @movie }
  #         else
  #           format.html { render action: 'new' }
  #           format.json { render json: @movie.errors, status: :unprocessable_entity }
  #         end
  #       end
  #     else
  #       flash[:error] = "Failed to download the image."
  #       render 'new'
  #     end
  #   else
  #     flash[:error] = "No search results found."
  #     render 'new'
  #   end
  # end
  
  
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

  def fetch_mpaa_rating(mpaa_movie_id)
    mpaa_url = URI("https://api.themoviedb.org/3/movie/#{mpaa_movie_id}/release_dates?api_key=#{ENV['APIKEY_TMDB']}")
    response = Net::HTTP.get(mpaa_url)
    data = JSON.parse(response)
    certification = data["results"].find { |result| result["iso_3166_1"] == "US" }&.dig("release_dates", 0, "certification")
    puts mpaa_url
    certification || "Not Rated"
  end

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