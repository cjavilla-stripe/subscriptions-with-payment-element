class PricingsController < ApplicationController
  def show
    @prices = Stripe::Price.list(
      active: true,
      recurring: { interval: params.fetch(:interval, 'month'),},
      currency: 'usd',
      expand: ['data.product'],
      lookup_keys: ['startup', 'freelancer', 'enterprise'],
    ).data.sort_by { |p| p.unit_amount }
    @prices.each do |price|
      price.features = JSON.parse(price.product.metadata.features)
    end
  end
end
