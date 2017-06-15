# Clear out the subscription and plan IDs and set the Manager.customer_type
# field to :free when a subscription is deleted
# Email the customer to let them know that the subscription has ended

require "stripe_event_subscribers/stripe_event_subscriber"

class CustomerSubscriptionDeleted < StripeEventSubscriber

  def call event
    customer_id = event.data.object.customer
    manager = Manager.where(stripe_customer_id: customer_id).first

    if manager.present?
      logger.info "[Stripe Webhook] Cancelling subscription for Manager '#{manager.slug}'"
      manager.update(stripe_subscription_id: nil,
                     stripe_payment_plan_id: nil,
                     customer_type: :free)
    else
      logger.error "[Stripe Webhook] Unable to find a Manager with Stripe customer_id: #{customer_id}"
    end
  end

end