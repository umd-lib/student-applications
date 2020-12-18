# frozen_string_literal: true

require 'test_helper'

# Unite tests for submitted mailer
class SubmittedMailerTest < ActionMailer::TestCase
  def setup
    @prospect = prospects(:all_valid)
  end

  test 'that we get an email' do
    email = SubmittedMailer.default_email(@prospect)

    assert_emails 1 do
      email.deliver_now
    end
    assert_equal 'We appreciate your interest in employment at UMD Libraries!', email.subject
    assert_equal @prospect.email, email.to.first
    assert_match "#{@prospect.first_name} #{@prospect.last_name}", email.html_part.body.to_s
    assert_match "#{@prospect.first_name} #{@prospect.last_name}", email.text_part.body.to_s
  end
end
