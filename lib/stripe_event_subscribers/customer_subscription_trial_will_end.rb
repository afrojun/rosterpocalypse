# Check whether we have a stored payment source for this customer. Email the
# customer notifying them if it is missing

require "stripe_event_subscribers/customer_subscription_event"

class CustomerSubscriptionTrialWillEnd < CustomerSubscriptionEvent
  def call(event)
    super do |manager|
      if manager.stripe_customer_sources.count.zero?
        logger.info "[Stripe Webhook] Sending email to ask the user to add a card."
        UserMailer.subscription_trial_will_end(manager.user).deliver_later
      else
        logger.info "[Stripe Webhook] Not sending trial end email."
      end
    end
  end
end