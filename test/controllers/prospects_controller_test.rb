require 'test_helper'

class ProspectsControllerTest < ActionController::TestCase

  test 'should allow authed users to deactivate a submitted application' do
    prospect = prospects(:all_valid) 
    refute prospect.suppressed?
    session[:cas] = { user: "admin" }
    post :deactivate, format: :json,  ids: [ prospect.id ]
    assert_response :success
    prospect.reload
    assert prospect.suppressed?
  end

end
