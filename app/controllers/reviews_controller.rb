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
        # @movie = Movie.find(params[:movie_id])
        # @review = @movie.reviews.build
      end
      
      
      
    
    # def create
    #     # since moviegoer_id is a protected attribute that won't get
    #     # assigned by the mass-assignment from params[:review], we set it
    #     # by using the << method on the association.  We could also
    #     # set it manually with review.moviegoer = @current_user.
    #     current_moviegoer.reviews << @movie.reviews.build(review_params)
    #     redirect_to movie_path(@movie)
    # end
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
    #   def create
    #     # ตรวจสอบว่ามีรีวิวสำหรับหนังนี้โดยผู้ใช้ปัจจุบันหรือไม่
    #     existing_review = current_moviegoer.reviews.find_by(movie_id: params[:movie_id])
        
    #     if existing_review
    #       flash[:notice] = "You have already reviewed this movie."
    #       redirect_to movie_path(@movie) and return
    #     else
    #       # การสร้างรีวิว
    #       @review = Review.new(review_params)
      
    #       if @review.save
    #         flash[:notice] = 'Review was successfully created.'
    #         redirect_to edit_review_path(@review) # สร้างรีวิวสำเร็จ ไปที่หน้าแก้ไขรีวิว
    #       else
    #         render 'new'
    #       end
    #     end
    #   end
    # def create
    #     existing_review = current_moviegoer.reviews.find_by(movie_id: params[:movie_id])
    #     @movie = Movie.find(params[:movie_id])
        
    #     if existing_review
    #       flash[:notice] = "You have already reviewed this movie."
    #       redirect_to movie_path(@movie) and return
    #     else
    #       @review = @movie.reviews.build(review_params)
      
    #       if @review.save
    #         flash[:notice] = 'Review was successfully created.'
    #         redirect_to edit_review_path(@review) # สร้างรีวิวสำเร็จ ไปที่หน้าแก้ไขรีวิว
    #       else
    #         render 'new'
    #       end
    #     end
    #   end
      
      
      
      
      
  
    # def edit
    #     @movie = Movie.find params[:movie_id]
    #     @review = Review.find params[:id]
    # end
  
    # def update
    #     @movie = Movie.find params[:movie_id]
    #     @review = Review.find params[:id]
    #     @review.update_attributes!(review_params)
    #     flash[:notice] = "#{@movie.title} review was successfully updated."
    #     redirect_to movie_path(@movie)
    # end

    def edit
        @review = Review.find(params[:id])
        @movie = @review.movie
      end
      
      def update
        @review = Review.find(params[:id])
        @review.update_attributes!(review_params)
        flash[:notice] = "Review was successfully updated."
        redirect_to movie_path(@review.movie)
      end
      
      def destroy
        @review = Review.find(params[:id])
        @review.destroy
        flash[:notice] = "Review was successfully deleted."
        redirect_to movie_path(@review.movie)
      end
      
  
    private
    def review_params
        params.require(:review).permit(:potatoes, :comments, :moviegoer, :movie)
    end
  end