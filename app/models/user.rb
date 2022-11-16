# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  stripe_customer_id     :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :stripe_customer_id, uniqueness: { allow_nil: true }

  has_many :subscriptions

  after_commit do
    if stripe_customer_id.blank?
      test_clock = Stripe::TestHelpers::TestClock.create(frozen_time: Time.now.to_i)

      customer = Stripe::Customer.create(
        email: email,
        test_clock: test_clock.id,
      )

      update(stripe_customer_id: customer.id)
    end
  end

  def subscribed?
    subscriptions.any? {|s| s.stripe_subscription_status == 'trialing' || s.stripe_subscription_status == 'active'}
  end
end
