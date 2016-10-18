require 'test_helper'

class SubmitProspectApplicationTest < ActionDispatch::IntegrationTest
  
  test "filling out the application" do
    visit "/"
    click_link "Apply!" 
  end

end
