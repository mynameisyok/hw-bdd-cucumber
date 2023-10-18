class Review < ActiveRecord::Base
    validates :movie_id, :presence => true
    validates_associated :movie
    belongs_to :movie
    belongs_to :moviegoer
    # validates :potatoes, presence: true, inclusion: { in: 1..5 }
    # validates :comments, presence: true, length: { minimum: 10 }
end