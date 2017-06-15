# Log the event type for all incoming calls

require "stripe_event_subscribers/stripe_event_subscriber"

class StripeEventLogger < StripeEventSubscriber

  def call event
    logger.info "[Stripe Webhook] #{event.type}"
  end

end