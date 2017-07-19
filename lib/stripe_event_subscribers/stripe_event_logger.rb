# Log the event type for all incoming calls

require "stripe_event_subscribers/stripe_event_handler"

class StripeEventLogger < StripeEventHandler
  def call(event)
    logger.info "[Stripe Webhook] #{event.type}"
  end
end