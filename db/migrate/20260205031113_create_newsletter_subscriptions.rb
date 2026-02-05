class CreateNewsletterSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :newsletter_subscriptions do |t|
      t.string :email, null: false
      t.references :user, null: true, foreign_key: true
      t.string :status, default: 'active', null: false
      t.string :unsubscribe_token, null: false
      t.datetime :subscribed_at
      t.datetime :unsubscribed_at

      t.timestamps
    end
    add_index :newsletter_subscriptions, :email, unique: true
    add_index :newsletter_subscriptions, :unsubscribe_token, unique: true
    add_index :newsletter_subscriptions, :status
  end
end
