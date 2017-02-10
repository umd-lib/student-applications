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

  test 'should log any problems' do


    class InvalidShoeSize <  ActiveRecord::ActiveRecordError; end

    Rails.logger.expects(:error).with(anything).at_least_once 
    Rails.logger.expects(:error).with("Uh-Oh!").at_least_once 
    Prospect.any_instance.stubs(:save).raises( InvalidShoeSize, "Uh-Oh!" ) 
    
   
    fixture = dup_fixture
    all_valid = JSON.parse(fixture.to_json).to_hash
    assert fixture.all_valid?

    all_valid[:enumeration_ids] = fixture.enumerations.map(&:id)
    all_valid.reject! { |a| %w(id created_at updated_at).include? a }

    all_valid['addresses_attributes'] = [ JSON.parse( addresses(:all_valid_springfield).to_json).to_hash.reject { |a| a == 'id' }]
    all_valid['available_times_attributes'] = []
    all_valid['available_hours_per_week'] = 0
    all_valid['phone_numbers_attributes'] = [ JSON.parse( phone_numbers(:all_valid_dummy).to_json).to_hash.reject { |a| a == 'id' }]
    
    session[:cas] = { user: "admin" }
    session[:prospect_step] = fixture.current_step
    
    refute_difference( 'Prospect.count' ) do
      post :create,  { prospect: all_valid }
    end 
    
    assert flash[:error] == "We're sorry, but something has gone wrong. Please try again."

  end
end
