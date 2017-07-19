# All the heavy lifting for updating statuses is handled in the parent class

require "stripe_event_subscribers/customer_subscription_event"

class CustomerSubscriptionUpdated < CustomerSubscriptionEvent
  def call(event)
    super
  end
end
