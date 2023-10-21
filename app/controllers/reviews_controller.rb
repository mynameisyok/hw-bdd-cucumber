# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
  before_action :has_moviegoer_and_movie, only: [:new, :create]
  
  protected
  def has_moviegoer_and_movie
    unless current_moviegoer
      flash[:warning] = 'You must be logged in to create a review.'
      redirect_back(fallback_location: root_path)
    end
    unless (@movie = Movie.find(params[:movie_id]))
      flash[:warning] = 'Review must be for an existing movie.'
      redirect_to movies_path
    end
  end
  
  public
  def new
    # ดึงข้อมูลหนังจาก params[:movie_id]
    @movie = Movie.find(params[:movie_id])
    # สร้าง review สำหรับหนังนี้
    @review = @movie.reviews.build
  end
    
  def create
      # ตรวจสอบว่ามีรีวิวสำหรับหนังนี้โดยผู้ใช้ปัจจุบันหรือไม่
      existing_review = current_moviegoer.reviews.find_by(movie_id: params[:movie_id])
  
      # ถ้ามีรีวิวอยู่แล้ว แจ้งเตือนผู้ใช้หรือทำตามความเหมาะสม
      if existing_review
        flash[:notice] = "You have already reviewed this movie."
        redirect_to movie_path(@movie) and return
      end
  
      # ถ้ายังไม่มีรีวิว ทำการสร้างรีวิวใหม่
      current_moviegoer.reviews << @movie.reviews.build(review_params)
      flash[:notice] = "Review successfully created."
      redirect_to movie_path(@movie)
    end

  def edit
    @movie = Movie.find(params[:movie_id])
    @review = @movie.reviews.find(params[:id])
  
    # ตรวจสอบว่าผู้ใช้ปัจจุบันตรงกับผู้เขียนรีวิวหรือไม่
    if current_moviegoer != @review.moviegoer
      flash[:warning] = "You don't have permission to edit this review."
      redirect_to movie_path(@movie)
    end
  end
  
  
  def update
    @movie = Movie.find(params[:movie_id])
    @review = @movie.reviews.find(params[:id])
    if @review.update(review_params)
      redirect_to movie_path(@movie), notice: "Review was successfully updated."
    else
      render :edit
    end
  end
  

  def destroy
    @review = Review.find(params[:id])
    if @review.moviegoer == current_moviegoer
      @review.destroy
      flash[:notice] = "Review was successfully deleted."
    else
      flash[:warning] = "You don't have permission to delete this review."
    end
    redirect_to movie_path(@review.movie)
  end
    
  private
  def review_params
      params.require(:review).permit(:potatoes, :comments, :moviegoer, :movie)
  end
end