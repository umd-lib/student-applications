# Mailer for successful application submissions
class SubmittedMailer < ApplicationMailer
  default from: 'no_reply@umd.edu'

  def default_email(prospect)
    logger.info('SubmittedMailer#default_email: Mail server=' +
                smtp_settings['address'.to_sym] +
                ", port=#{smtp_settings['port'.to_sym]}")
    @prospect = prospect
    mail(to: @prospect.email, subject: 'We appreciate your interest in employment at UMD Libraries!')
  end
end
