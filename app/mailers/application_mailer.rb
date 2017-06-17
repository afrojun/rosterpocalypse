class ApplicationMailer < ActionMailer::Base
  default from: '"Rosterpocalypse" <admin@rosterpocalypse.com>',
          reply_to: 'rosterpocalypse@gmail.com'
  layout 'mailer'
end
