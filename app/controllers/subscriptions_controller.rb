class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def new
    @price = Stripe::Price.retrieve(id: params[:price], expand: ['product'])
    pending_subscriptions = Stripe::Subscription.list(
      customer: current_user.stripe_customer_id,
      status: 'incomplete',
      expand: ['data.latest_invoice.payment_intent']
    ).data
    if pending_subscriptions.any?
      @subscription = pending_subscriptions.last
    else
      @subscription = Stripe::Subscription.create(
        default_tax_rates: ['txr_1HyTIyCZ6qsJgndJ1bkkD55H'],
        metadata: {
          user_id: current_user.id,
          company_id: '123',
        },
        currency: 'usd',
        customer: current_user.stripe_customer_id,
        payment_behavior: 'default_incomplete',
        items: [{
          price: params[:price],
          quantity: 1,
        }],
        payment_settings: {
          save_default_payment_method: 'on_subscription',
        },
        expand: ['latest_invoice.payment_intent'],
      )
    end

    @payment_methods = Stripe::PaymentMethod.list(
      customer: current_user.stripe_customer_id,
      type: 'card',
    )
  end

  def index
    @subscriptions = current_user.subscriptions.where.not(stripe_subscription_status: :incomplete_expired)
  end
end
