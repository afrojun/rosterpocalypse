# Ensure that the Strip customer subscription status in the DB matches what is
# sent in the Stripe webhook call, except in the case of subscriptions that are
# scheduled to be terminated at the end of the current period. These should have
# a status of :do_not_renew

require "stripe_event_subscribers/stripe_event_subscriber"

class CustomerSubscriptionEvent < StripeEventSubscriber

  def call event
    customer_id = event.data.object.customer
    manager = Manager.where(stripe_customer_id: customer_id).first

    if manager.present?
      # TODO: Check that the subscription being updated is the current stored one


      status = if event.data.object.status != "canceled" && event.data.object.cancel_at_period_end
                 :do_not_renew
               else
                 event.data.object.status
               end
      logger.info "[Stripe Webhook] Setting subscription for #{manager.slug} to #{status}"
      manager.update(subscription_status: status.to_sym)
    else
      logger.error "[Stripe Webhook] Unable to find a Manager with Stripe customer_id: #{customer_id}"
    end
  end

end