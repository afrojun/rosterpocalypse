class UserMailer < ApplicationMailer
  layout 'user_mailer'

  # New subscription confirmation email
  def subscription_created user
    send_email user, 'Premium subscription confirmation'
  end

  # 3 days before the end of the subscription, remind users to add payment details
  def subscription_trial_will_end user
    send_email user, 'Premium trial period ending soon'
  end

  # Confirm that the subscription has been cancelled, but will continue till the
  # end of the current billing cycle
  def subscription_cancelled user
    send_email user, 'Premium subscription cancelled'
  end

  # Confirm that the subscription has ended
  def subscription_deleted user
    send_email user, 'Premium subscription ended'
  end

  # Confirm reactivation of the subscription
  def subscription_reactivated user
    send_email user, 'Premium subscription reactivated'
  end

  # Inform users when a payment attempt fails
  def subscription_payment_past_due user
    @card = user.manager.stripe_customer_default_source
    send_email user, 'Subscription payment failed'
  end

  protected

    def send_email user, subject
      @user = user
      mail(to: %("#{@user.username}" <#{@user.email}>),
           bcc: "rosterpocalypse@gmail.com",
           subject: "Rosterpocalypse: #{subject}")
    end

end
