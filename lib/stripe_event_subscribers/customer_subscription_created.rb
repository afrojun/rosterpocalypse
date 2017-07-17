# Set the Manager.customer_type field to :paid when a subscription is created.
# Email the customer to let them know that the subscription has begun

require "stripe_event_subscribers/customer_subscription_event"

class CustomerSubscriptionCreated < CustomerSubscriptionEvent
  def call event
    super do |manager|
      logger.info "[Stripe Webhook] Setting customer type for Manager '#{manager.slug}' to 'paid'"
      manager.update(customer_type: :paid)

      UserMailer.subscription_created(manager.user).deliver_later
    end
  end
end