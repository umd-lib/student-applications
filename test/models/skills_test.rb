require 'test_helper'


class SkillTest < ActiveSupport::TestCase

  def setup
  end

  test "can create a valid record" do
    skill = Skill.new name: 'swimming'
    assert skill.valid?
  end
  
  test "can be associated to a prospect" do
    prospect = Prospect.create current_step: "skills_step", skills_attributes: { "0": { name: 'fishing'  } }
    assert prospect.skills.first.valid? 
    assert_equal prospect.skills.first.name, "fishing" 
  end
  

end
