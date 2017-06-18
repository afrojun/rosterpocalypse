class Manager < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  STRIPE_SUBSCRIPTION_PLAN_ID = "rosterpocalypse-premium-1.0"
  STRIPE_SUBSCRIPTION_TRIAL_PLAN_ID = "rosterpocalypse-premium-with-trial-1.0"

  enum customer_type: [:free, :paid]
  enum subscription_status: [:unsubscribed, :pending, :trialing, :active, :past_due, :canceled, :unpaid, :do_not_renew]

  belongs_to :user
  has_many :rosters, dependent: :destroy
  has_many :leagues, dependent: :destroy
  has_many :roster_leagues, through: :rosters, source: :leagues

  def name
    user.try :username
  end

  def name_changed?
    user.try :username_changed?
  end

  def private_leagues
    leagues.where(type: "PrivateLeague")
  end

  def participating_in_private_leagues
    (rosters.map(&:private_leagues).flatten + private_leagues.to_a).uniq
  end

  def stripe_customer
    @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
  end

  def stripe_customer_sources
    @stripe_customer_sources ||= stripe_customer.sources
  end

  def any_stripe_customer_sources?
    stripe_customer_sources.any?
  rescue
    false
  end

  def stripe_customer_default_source
    @stripe_customer_default_source ||= begin
      if any_stripe_customer_sources?
        card_id = stripe_customer["default_source"]
        stripe_customer_sources.retrieve card_id
      else
        nil
      end
    end
  end

  def create_stripe_customer stripe_token
    customer = Stripe::Customer.create(
      email: user.email,
      description: "Customer for #{user.email}",
      source: stripe_token
    )
    update(stripe_customer_id: customer.id)
  end

  def update_stripe_customer_source stripe_token
    stripe_customer.source = stripe_token
    stripe_customer.save
  end

  def remove_stripe_customer_source card_id
    stripe_customer_sources.retrieve(card_id).delete()
  end

  def allow_payment_source_removal?
    ["unsubscribed", "canceled", "do_not_renew"].include?(subscription_status) ||
      stripe_customer_sources.count > 1
  end

  def stripe_subscription
    @stripe_subscription ||= Stripe::Subscription.retrieve(stripe_subscription_id)
  end

  def create_stripe_subscription
    # Sign up for a plan with a trial plan if the customer has not used the trial before
    plan = canceled? ? STRIPE_SUBSCRIPTION_PLAN_ID : STRIPE_SUBSCRIPTION_TRIAL_PLAN_ID
    subscription = Stripe::Subscription.create(
      customer: stripe_customer_id,
      plan: plan
    )

    update(stripe_subscription_id: subscription.id,
           stripe_payment_plan_id: plan,
           subscription_status: :pending)
  end

  def delete_stripe_subscription
    stripe_subscription.delete(at_period_end: true)
    update(subscription_status: :do_not_renew)
  end

  def reactivate_stripe_subscription
    stripe_subscription.tap do |sub|
      sub.plan = stripe_payment_plan_id
      sub.save
    end
    update(subscription_status: :pending)
  end
end
