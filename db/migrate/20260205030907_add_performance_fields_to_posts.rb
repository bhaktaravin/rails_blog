class AddPerformanceFieldsToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :views_count, :integer, default: 0, null: false
    add_column :posts, :published, :boolean, default: true, null: false
    
    add_index :posts, :views_count
    add_index :posts, :published
  end
end
