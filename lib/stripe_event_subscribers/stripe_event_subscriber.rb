class StripeEventSubscriber

  attr_reader :logger

  def initialize logger
    @logger = logger
  end

end