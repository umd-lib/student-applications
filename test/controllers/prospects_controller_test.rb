# frozen_string_literal: true

require "test_helper"

class ProspectsControllerTest < ActionController::TestCase
  class InvalidShoeSize < ActiveRecord::ActiveRecordError; end

  test "should log any problems" do
    Rails.logger.expects(:error).with(anything).at_least_once
    Rails.logger.expects(:error).with("Uh-Oh!").at_least_once
    Prospect.any_instance.stubs(:save).raises(InvalidShoeSize, "Uh-Oh!")

    fixture = dup_fixture
    all_valid = JSON.parse(fixture.to_json).to_hash
    assert fixture.all_valid?

    all_valid[:enumeration_ids] = fixture.enumerations.map(&:id)
    all_valid.reject! { |a| %w[id created_at updated_at].include? a }

    all_valid["addresses_attributes"] = [ JSON.parse(addresses(:all_valid_springfield).to_json).to_hash.reject { |a| a == "id" } ]
    all_valid["available_times_attributes"] = []
    all_valid["available_hours_per_week"] = 0
    all_valid["phone_numbers_attributes"] = [ JSON.parse(phone_numbers(:all_valid_dummy).to_json).to_hash.reject { |a| a == "id" } ]

    session[:prospect_step] = fixture.current_step

    assert_no_difference("Prospect.count") do
      post :create,  params: { prospect: all_valid }
    end

    assert flash[:error] == "We're sorry, but something has gone wrong. Please try again."
  end

  test "convert_attributes_param_to_safe_hash should allow only whitelisted parameters" do
    address_attributes_hash = {
      "0" => {
        "address_type" => "local", "street_address_1" => "555 Fake St",
        "street_address_2" => "", "city" => "Springfield", "state" => "HI",
        "postal_code" => "12345", "country" => "US",
        "malicious_value" => "this value should not be passed through"
      }
    }

    address_attributes_param = ActionController::Parameters.new(address_attributes_hash)
    controller = ProspectsController.new
    result = controller.send(:convert_attributes_param_to_safe_hash, "addresses_attributes", address_attributes_param)

    assert result.key?("0")
    assert result["0"].is_a?(Hash)

    # expected_keys should be sorted alphabetically
    expected_keys = %w[address_type city country postal_code state
                       street_address_1 street_address_2]
    assert_equal expected_keys, result["0"].keys.sort
    assert_not result["0"].key?("malicious_value")
  end

  test "convert_attributes_param_to_safe_hash work should handle multiple instances of attribute" do
    address_attributes_hash = {
      "0" => {
        "address_type" => "local", "street_address_1" => "555 Fake St",
        "street_address_2" => "", "city" => "Springfield", "state" => "HI",
        "postal_code" => "12345", "country" => "US",
        "malicious_value" => "this value should not be passed through"
      },
      "1" => {
        "address_type" => "permanent", "street_address_1" => "123 Main St",
        "street_address_2" => "", "city" => "Anytown", "state" => "MD",
        "postal_code" => "54321", "country" => "US",
        "malicious_value" => "this value should not be passed through"
      }
    }

    address_attributes_param = ActionController::Parameters.new(address_attributes_hash)
    controller = ProspectsController.new
    result = controller.send(:convert_attributes_param_to_safe_hash, "addresses_attributes", address_attributes_param)

    assert result.key?("0")
    assert_equal "Springfield", result["0"]["city"]

    assert result.key?("1")
    assert result["1"].is_a?(Hash)
    assert_equal "Anytown", result["1"]["city"]
    assert_not result["1"].key?("malicious_value")
  end

  test "admin-only params are ignored if submitted by applicant" do
    # Set up parameters for a complete valid submission
    fixture = dup_fixture
    all_valid_params = fixture.attributes.with_indifferent_access
    all_valid_params[:enumeration_ids] = fixture.enumerations.map(&:id)
    all_valid_params.reject! { |a| %w[id created_at updated_at].include? a }

    all_valid_params[:semester] = Enumeration.active_semesters.first.value

    all_valid_params[:addresses_attributes] = [ addresses(:all_valid_springfield).attributes.reject { |a| a == "id" } ]
    all_valid_params[:phone_numbers_attributes] = [ phone_numbers(:all_valid_dummy).attributes.reject { |a| a == "id" } ]
    all_valid_params[:available_times_attributes] = [ available_times(:all_valid_sunday).attributes.reject { |a| a == "id" } ]

    # Attempt to set admin-only parameters
    all_valid_params[:hired] = true
    all_valid_params[:hr_comments] = "HR Comment submitted by user"
    all_valid_params[:suppressed] = true

    session[:prospect_step] = Prospect.steps.last
    post :create, params: { prospect: all_valid_params }

    prospect = Prospect.find_by(directory_id: all_valid_params[:directory_id])

    # Admin-only parameters have not been changed
    assert_equal false, prospect.hired, "'hired' should not be settable by applicant"
    assert_nil prospect.hr_comments, "'hr_comments' should not be settable by applicant"
    assert_equal false, prospect.suppressed, "'suppressed' should not be settable by applicant"
  end
end
