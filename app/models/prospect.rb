# This is a model for a application
# It includes the steps that are used to submit one
class Prospect < ActiveRecord::Base


  # these are the validations for the contact_information step
  validates_inclusion_of :in_federal_study, in: [true,false], if: ->(o) { o.current_step == "contact_info" } 
  %i( directory_id first_name last_name local_address local_phone
      email graduation_year  ).each do |attr|
      validates_presence_of attr, if: ->(o) { o.current_step == "contact_info" }
    end


  has_many :work_experiences
  accepts_nested_attributes_for :work_experiences, allow_destroy: true
  
  has_many :available_times
  accepts_nested_attributes_for :available_times, allow_destroy: true

  has_and_belongs_to_many :skills
  accepts_nested_attributes_for :skills

  attr_accessor :skill_ids
  attr_writer :current_step

  enum class_status: %i{ Undergraduate Graduate } 
  enum graduation_year: (2016..2020).map { |year| [ "#{year}_dec".intern, "#{year}_may".intern ] }.flatten 

  def self.steps
    %w( contact_info work_experience skills availability comments_confirmation  )
  end

  def steps
    self.class.steps
  end

  def current_step
    @current_step || steps.first
  end


  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end
  
  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end
  
  def first_step?
    current_step == steps.first
  end
  
  def last_step?
    current_step == steps.last
  end
  
  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end

end
