# Check whether we have a stored payment source for this customer. Email the
# customer notifying them if it is missing

require "stripe_event_subscribers/stripe_event_subscriber"

class CustomerSubscriptionTrialWillEnd < StripeEventSubscriber

  def call event
    customer_id = event.data.object.customer
    manager = Manager.where(stripe_customer_id: customer_id).first

    if manager.present?
      logger.info "[Stripe Webhook] Setting customer type for Manager '#{manager.slug}' to 'paid'"
      manager.update(customer_type: :paid)
    else
      logger.error "[Stripe Webhook] Unable to find a customer with Stripe customer_id: #{customer_id}"
    end
  end

end