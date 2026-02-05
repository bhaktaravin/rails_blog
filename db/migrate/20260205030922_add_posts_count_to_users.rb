class AddPostsCountToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :posts_count, :integer, default: 0, null: false
    
    # Reset counter cache for existing users
    reversible do |dir|
      dir.up do
        User.find_each do |user|
          User.reset_counters(user.id, :posts)
        end
      end
    end
  end
end
