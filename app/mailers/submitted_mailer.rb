class SubmittedMailer < ApplicationMailer
  default from: 'no_reply@umd.edu'

  def default_email(prospect)
    @prospect = prospect
    mail(to: @prospect.email, subject: 'We appreciate your interest in employment at UMD Libraries!')
  end
end
