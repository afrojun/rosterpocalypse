class ApplicationMailer < ActionMailer::Base
  default from: '"Rosterpocalypse" <admin@rosterpocalypse.com>'
  layout 'mailer'

  # Inform admins when a Stripe webhook call fails
  def stripe_webhook_failure event, error
    @event = event
    @error = error
    mail(to: '"Rosterpocalypse" <rosterpocalypse@gmail.com>',
         subject: "Stripe Webhook Failure")
  end
end
