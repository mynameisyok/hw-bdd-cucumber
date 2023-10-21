class CreateMovies < ActiveRecord::Migration[5.2]
  def up
    create_table :movies do |t|
      t.string :title
      t.string :rating
      t.text :description
      t.date :release_date
      t.string :image
      t.timestamps
    end

    add_index :movies, :title, unique: true
  end

  def down
    drop_table :movies
  end
end
