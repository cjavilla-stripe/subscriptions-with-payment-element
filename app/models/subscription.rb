# == Schema Information
#
# Table name: subscriptions
#
#  id                         :bigint           not null, primary key
#  stripe_subscription_status :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  stripe_price_id            :string
#  stripe_subscription_id     :string           not null
#  user_id                    :bigint           not null
#
# Indexes
#
#  index_subscriptions_on_stripe_subscription_id  (stripe_subscription_id) UNIQUE
#  index_subscriptions_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Subscription < ApplicationRecord
  belongs_to :user
end
