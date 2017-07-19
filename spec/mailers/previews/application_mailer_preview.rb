# Preview all emails at http://localhost:5000/rails/mailers/application_mailer
class ApplicationMailerPreview < ActionMailer::Preview
  def stripe_webhook_failure
    raise 'Test error'
  rescue => error
    event = OpenStruct.new(type: 'test')
    ApplicationMailer.stripe_webhook_failure event, error
  end
end
