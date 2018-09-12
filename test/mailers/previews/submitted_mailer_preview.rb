# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/submitted_mailer
class SubmittedMailerPreview < ActionMailer::Preview
  def sample_mail_preview
    SubmittedMailer.sample_email(User.first)
  end
end
