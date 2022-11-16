class CreateSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :subscriptions do |t|
      t.string :stripe_subscription_id, null: false
      t.string :stripe_subscription_status
      t.string :stripe_price_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :subscriptions, :stripe_subscription_id, unique: true
  end
end
