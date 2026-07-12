# frozen_string_literal: true

# Base mailer configuration for all application mailers.
class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'
end
