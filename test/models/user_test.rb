require 'test_helper'

class UserTest < ActiveSupport::TestCase
   test "can create a valid user" do
     user = User.new
     assert user.valid?
   end

   test "default is not an admin" do
     refute User.new.admin?
   end

end
