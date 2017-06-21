# This is the parent class to all other Stripe Subscription event handlers.
#
# It does basic validation of the incoming webhook and ensures that the Stripe
# customer subscription status in the DB matches what is sent in the webhook
# call, except in the case of subscriptions that are scheduled to be terminated
# at the end of the current period. These should have a status of :do_not_renew
#
# It then yields to allow further processing of the incoming webhook if a block
# is passed in.

require "stripe_event_subscribers/stripe_event_handler"

class CustomerSubscriptionEvent < StripeEventHandler

  def call event
    customer_id = event.data.object.customer
    stripe_object_id = event.data.object.id
    manager = Manager.where(stripe_customer_id: customer_id).first

    if manager.present?
      if stripe_object_id == manager.stripe_subscription_id

        old_status = manager.subscription_status.to_sym
        new_status = if event.data.object.status != "canceled" && event.data.object.cancel_at_period_end
                   :do_not_renew
                 else
                   event.data.object.status.to_sym
                 end

        if old_status != new_status
          logger.info "[Stripe Webhook] Changing subscription status for #{manager.slug} " +
                      "from '#{old_status}' to '#{new_status}'."
          manager.update(subscription_status: new_status)

          # Handle state transition to/from :past_due and :do_not_renew
          if new_status == :past_due
            manager.free!
            UserMailer.subscription_payment_past_due(manager.user).deliver_later
          elsif new_status == :do_not_renew
            UserMailer.subscription_cancelled(manager.user).deliver_later
          elsif [:trialing, :active].include?(new_status) && old_status == :do_not_renew
            UserMailer.subscription_reactivated(manager.user).deliver_later
          elsif [:past_due, :unpaid].include?(old_status) && new_status == :active
            manager.paid!
          end
        end

        yield(manager) if block_given?
      else
        logger.error "[Stripe Webhook] Manager '#{manager.slug}' has a subscription ID of " +
                     "'#{manager.stripe_subscription_id}', which does not match the webhook" +
                     "event subscription ID of '#{stripe_object_id}'."
      end
    else
      logger.error "[Stripe Webhook] Unable to find a Manager with Stripe customer_id: #{customer_id}"
    end
  rescue => e
    logger.error "An unexpected error occurred: [#{e.class}] #{e.message}"
    logger.error "Backtrace: #{e.backtrace.join("\n")}"

    # Send an email to the Rosterpocalypse admin email address to investigate further
    ApplicationMailer.stripe_webhook_failure(event, e).deliver_later
  end

end