class Manager < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  enum customer_type: [:free, :paid]
  enum subscription_status: [:inactive, :pending, :subscribed, :error]

  belongs_to :user
  has_many :rosters, dependent: :destroy
  has_many :leagues, dependent: :destroy

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
    stripe_customer.sources.retrieve(card_id).delete()
  end
end
