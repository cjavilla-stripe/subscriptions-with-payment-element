class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      status 400
      return
    end

    case event.type
    when 'invoice.payment_succeeded'
      invoice = event.data.object
      if invoice.billing_reason == 'subscription_create'
        customer_id = data_object.customer
        payment_intent = Stripe::PaymentIntent.retrieve(invoice.payment_intent)

        customer = Stripe::Customer.update(
          invoice_settings: {
            default_payment_method: payment_intent.payment_method
          }
        )
      end
    when 'customer.subscription.created', 'customer.subscription.updated', 'customer.subscription.deleted'
      subscription = event.data.object # contains a Stripe::Subscription object
      user = User.find_by(stripe_customer_id: subscription.customer)
      sub = user.subscriptions.find_by(stripe_subscription_id: subscription.id)
      if sub.nil?
        user.subscriptions.create(
          stripe_subscription_id: subscription.id,
          stripe_subscription_status: subscription.status,
          stripe_price_id: subscription.items.data.first.id
        )
      else
        sub.update(
          stripe_subscription_status: subscription.status,
          stripe_price_id: subscription.items.data.first.id
        )
      end
    end

    render json: { message: 'success' }
  end
end
