class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
  
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :body, presence: true, length: { minimum: 10, maximum: 10_000 }
  validates :user, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :published, -> { where(published: true) }
  scope :popular, -> { order(views_count: :desc) }
  
  after_create_commit :clear_post_cache
  after_update_commit :clear_post_cache
  after_destroy_commit :clear_post_cache
  
  def increment_views
    increment!(:views_count)
  end
  
  private
  
  def clear_post_cache
    Rails.cache.delete(["posts", "index"])
    Rails.cache.delete(["post", id])
  end
end
