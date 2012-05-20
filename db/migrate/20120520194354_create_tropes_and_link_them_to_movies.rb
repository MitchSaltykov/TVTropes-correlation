class CreateTropesAndLinkThemToMovies < ActiveRecord::Migration
  def change
    create_table :tropes do |t|
      t.string :name
      t.string :url

      t.timestamps
    end

    create_table :movie_tropes do |t|
      t.integer :movie_id
      t.integer :trope_id

      t.timestamps
    end
  end
end
