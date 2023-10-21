class AddImageToMovies < ActiveRecord::Migration[6.0]
  def change
    add_column :movies, :image, :string unless column_exists?(:movies, :image)
  end
end

# class AddImageToMovies < ActiveRecord::Migration[6.0]
#   def change
#     add_column :movies, :image, :jsonb
#   end
# end
