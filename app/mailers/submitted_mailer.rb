# frozen_string_literal: true

# Mailer for successful application submissions
class SubmittedMailer < ApplicationMailer
  default from: 'no_reply@umd.edu'

  # rubocop:disable Layout/LineLength
  def default_email(prospect)
    logger.info "#{self.class}##{__method__}: sent to #{smtp_settings[:address] || 'NONE'}:#{smtp_settings[:port] || 'NONE'}"
    @prospect = prospect
    mail(to: @prospect.email, subject: 'We appreciate your interest in employment at UMD Libraries!')
  end
  # rubocop:enable Layout/LineLength
end
