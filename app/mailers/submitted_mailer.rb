class SubmittedMailer < ApplicationMailer

  default from: "no_reply@umd.edu"

  def default_email(prospect)
    @prospect = prospect
    mail( to: @prospect.email, subject: "Thanks for your application!" )
  end

end
