# frozen_string_literal: true

require 'test_helper'

# Unit tests for users
class UserTest < ActiveSupport::TestCase
  test 'can create a valid user' do
    user = User.new
    assert user.valid?
  end

  test 'default is not an admin' do
    assert_not User.new.admin?
  end
end
