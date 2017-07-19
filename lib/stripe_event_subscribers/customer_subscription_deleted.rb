# Clear out the subscription and plan IDs and set the Manager.customer_type
# field to :free when a subscription is deleted
# Email the customer to let them know that the subscription has ended

require 'stripe_event_subscribers/customer_subscription_event'

class CustomerSubscriptionDeleted < CustomerSubscriptionEvent
  def call(event)
    super do |manager|
      logger.info "[Stripe Webhook] Cancelling subscription for Manager '#{manager.slug}'"
      manager.update(stripe_subscription_id: nil,
                     stripe_payment_plan_id: nil,
                     customer_type: :free)

      # UserMailer.subscription_deleted(manager.user).deliver_later
    end
  end
end
