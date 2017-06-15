require "stripe_event_subscribers/stripe_event_logger"
require "stripe_event_subscribers/customer_subscription_event"
require "stripe_event_subscribers/customer_subscription_created"
require "stripe_event_subscribers/customer_subscription_deleted"

Rails.configuration.stripe = {
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

StripeEvent.configure do |events|
  events.all StripeEventLogger.new(Rails.logger)
  events.subscribe 'customer.subscription.', CustomerSubscriptionEvent.new(Rails.logger)
  events.subscribe 'customer.subscription.created', CustomerSubscriptionCreated.new(Rails.logger)
  events.subscribe 'customer.subscription.deleted', CustomerSubscriptionDeleted.new(Rails.logger)
  #events.subscribe 'customer.subscription.trial_will_end', CustomerSubscriptionTrialWillEnd.new(Rails.logger)
end