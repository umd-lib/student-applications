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

  test 'Semester field should be filterable' do
    session[:cas] = { user: "admin" }
    spring_2018 = enumerations(:spring_2018)
    search_criteria = [spring_2018.id]
    get :index, { search: { enumerations: search_criteria } }

    all_request_ids = assigns(:all_results)

    # Make sure we filtered one or more records
    assert all_request_ids.count < Prospect.count

    all_request_ids.each do |id|
      prospect = Prospect.find(id)
      assert_equal spring_2018, prospect.semester,
                    "Incorrect semester for #{prospect.id} - #{prospect.last_name}, #{prospect.first_name}"
    end
  end

  test 'Class Status field should be filterable' do
    session[:cas] = { user: "admin" }
    undergraduate = enumerations(:undergraduate)
    search_criteria = [undergraduate.id]
    get :index, { search: { enumerations: search_criteria } }

    all_request_ids = assigns(:all_results)

    # Make sure we filtered one or more records
    assert all_request_ids.count < Prospect.count

    all_request_ids.each do |id|
      prospect = Prospect.find(id)
      assert_equal undergraduate, prospect.class_status,
                   "Incorrect class status for #{prospect.id} - #{prospect.last_name}, #{prospect.first_name}"
    end
  end

  test 'Preferred Library field should be filterable' do
    session[:cas] = { user: "admin" }
    art_library = enumerations(:art_library)
    search_criteria = [art_library.id]
    get :index, { search: { enumerations: search_criteria } }

    all_request_ids = assigns(:all_results)

    # Make sure we filtered one or more records
    assert all_request_ids.count < Prospect.count

    all_request_ids.each do |id|
      prospect = Prospect.find(id)
      assert prospect.libraries.include?(art_library),
            "Incorrect preferred libraries for #{prospect.id} - #{prospect.last_name}, #{prospect.first_name} - libraries: #{prospect.libraries}"
    end
  end

  test 'Filtering on multiple Class Status fields should be ORed' do
    session[:cas] = { user: "admin" }
    undergraduate = enumerations(:undergraduate)
    graduate = enumerations(:graduate)
    search_criteria = [undergraduate.id, graduate.id]
    get :index, { search: { enumerations: search_criteria } }

    all_request_ids = assigns(:all_results)

    # Should get all the records (since Class Status is required, and there
    # are only two options)
    assert all_request_ids.count == Prospect.count
  end

  test 'Filtering on multiple Preferred Library field should be ORed' do
    session[:cas] = { user: "admin" }
    art_library = enumerations(:art_library)
    engineering_library = enumerations(:engineering_library)
    search_criteria = [art_library, engineering_library.id]
    get :index, { search: { enumerations: search_criteria } }

    all_request_ids = assigns(:all_results)

    # Make sure we filtered one or more records
    assert all_request_ids.count < Prospect.count

    all_request_ids.each do |id|
      prospect = Prospect.find(id)
      libraries = prospect.libraries
      assert (libraries.include?(art_library) || libraries.include?(engineering_library)),
             "Incorrect preferred libraries for #{prospect.id} - #{prospect.last_name}, #{prospect.first_name} - libraries: #{prospect.libraries}"
    end
  end

  test 'Class Status and Semester filters should be ANDed together' do
    session[:cas] = { user: "admin" }

    undergraduate = enumerations(:undergraduate)
    spring_2018 = enumerations(:spring_2018)
    search_criteria = [undergraduate.id, spring_2018.id]

    get :index, { search: { enumerations: search_criteria } }

    all_request_ids = assigns(:all_results)

    # Make sure we filtered one or more records
    assert all_request_ids.count < Prospect.count
    assert all_request_ids.count > 0

    all_request_ids.each do |id|
      prospect = Prospect.find(id)
      assert_equal undergraduate, prospect.class_status,
                   "Incorrect class status for #{prospect.id} - #{prospect.last_name}, #{prospect.first_name}"
      assert_equal spring_2018, prospect.semester,
                   "Incorrect semester for #{prospect.id} - #{prospect.last_name}, #{prospect.first_name}"
    end
  end

  test 'Class Status, Semester and Preferred Libraries filters should be ANDed together' do
    session[:cas] = { user: "admin" }

    undergraduate = enumerations(:undergraduate)
    spring_2018 = enumerations(:spring_2018)
    engineering_library = enumerations(:engineering_library)
    search_criteria = [undergraduate.id, spring_2018.id, engineering_library.id]

    get :index, { search: { enumerations: search_criteria } }

    all_request_ids = assigns(:all_results)

    # Make sure we filtered one or more records
    assert all_request_ids.count < Prospect.count
    assert all_request_ids.count > 0

    all_request_ids.each do |id|
      prospect = Prospect.find(id)
      assert_equal undergraduate, prospect.class_status,
                   "Incorrect class status for #{prospect.id} - #{prospect.last_name}, #{prospect.first_name}"
      assert_equal spring_2018, prospect.semester,
                   "Incorrect semester for #{prospect.id} - #{prospect.last_name}, #{prospect.first_name}"
      assert_contains prospect.libraries, engineering_library
                   "Incorrect library for #{prospect.id} - #{prospect.last_name}, #{prospect.first_name}"
    end
  end
end
