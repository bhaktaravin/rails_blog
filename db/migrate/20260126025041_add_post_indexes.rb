class AddPostIndexes < ActiveRecord::Migration[8.1]
  def change
    # Add index for faster queries on created_at (used in ordering)
    add_index :posts, :created_at
    
    # Add index on user_id + created_at for user's posts queries
    add_index :posts, [:user_id, :created_at]
  end
end
