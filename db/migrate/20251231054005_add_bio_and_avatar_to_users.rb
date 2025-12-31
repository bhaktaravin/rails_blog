class AddBioAndAvatarToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :bio, :text
    add_column :users, :avatar, :string
  end
end
