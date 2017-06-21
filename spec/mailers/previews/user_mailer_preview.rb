# Preview all emails at http://localhost:5000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def phase_2_announcement
    UserMailer.phase_2_announcement User.first
  end

  def subscription_created
    UserMailer.subscription_created User.first
  end

  def subscription_trial_will_end
    UserMailer.subscription_trial_will_end User.first
  end

  def subscription_cancelled
    UserMailer.subscription_cancelled User.first
  end

  def subscription_deleted
    UserMailer.subscription_deleted User.first
  end

  def subscription_reactivated
    UserMailer.subscription_reactivated User.first
  end

  def subscription_payment_past_due
    UserMailer.subscription_payment_past_due User.first
  end
end
