# Set the Manager.customer_type field to :paid when a subscription is created.
# Email the customer to let them know that the subscription has begun

require "stripe_event_subscribers/stripe_event_subscriber"

class CustomerSubscriptionCreated < StripeEventSubscriber

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