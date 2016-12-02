# This is a model for a application
# It includes the steps that are used to submit one
class Prospect < ActiveRecord::Base
  include Walkable

  belongs_to :resume
  after_initialize :after_initialize

  # this makes sure we have a local address and that has_family_member is set
  # correctly
  def after_initialize
    local_address # we call this to make sure we have one.
    @has_family_member = if @has_family_member.nil?
                           !family_member.blank?
                         else
                           ActiveRecord::Type::Boolean.new.type_cast_from_user(@has_family_member)
                         end
  end

  # if has_family_member = false but we do have a family_member value, we
  # should return true.
  def family_member?
    ActiveRecord::Type::Boolean.new.type_cast_from_user(@has_family_member) || !family_member.blank?
  end

  # this validates if the user has clicked "All information is correct" on last
  # step
  validates :user_confirmation, acceptance: true, if: ->(p) { p.last_step? }
  validates :user_signature, presence: true, if: ->(p) { p.last_step? }

  # these are the validations for the contact_information step
  validates :in_federal_study, inclusion: { in: [true, false], if: ->(p) { p.current_step == 'contact_info' } }
  %i(directory_id first_name last_name email graduation_year class_status).each do |attr|
    validates attr, presence: true, if: ->(p) { p.current_step == 'contact_info' }
  end

  has_many :work_experiences
  accepts_nested_attributes_for :work_experiences, allow_destroy: true

  has_many :available_times
  accepts_nested_attributes_for :available_times, allow_destroy: true

  # the number of available hours per week should =< number of available_times
  validate :available_hours_per_week_gt_available_times
  validates_numericality_of :available_hours_per_week, greater_than_or_equal_to: 0

  def available_hours_per_week_gt_available_times
    if available_hours_per_week > available_times.size
      errors.add(:available_hours_per_week, "can't be greater than the number of available times provided.")
    end
  end

  def name
    "#{last_name}, #{first_name}"
  end

  # this is a way of feeding day-times into the prospect and have them stored
  # in
  attr_accessor :day_times
  def day_times
    @day_times || []
  end

  def day_times=(dts)
    available_times.destroy_all
    dts.each do |dt|
      day, time = dt.split('-').map(&:to_i)
      available_times.find_or_initialize_by(day: day, time: time)
    end
    @day_times = available_times.map(&:day_time)
  end

  has_many :phone_numbers, inverse_of: :prospect
  accepts_nested_attributes_for :phone_numbers

  has_many :addresses, inverse_of: :prospect
  accepts_nested_attributes_for :addresses, allow_destroy: true
  #  validates_associated :addresses, if: ->(o) { o.current_step == "contact_info" }

  # by default we want to have one local_address, either a new one we've built
  # or an address that has been provided
  def local_address_with_default
    addresses.find(&:local?) || addresses.build(address_type: 'local')
  end

  has_one :local_address, -> { where(address_type: 'local') }, class_name: Address
  accepts_nested_attributes_for :local_address, allow_destroy: true

  alias_method_chain :local_address, :default
  validates :local_address, presence: true, if: ->(o) { o.current_step == 'contact_info' }

  has_one :permanent_address, -> { where(address_type: 'permanent') }, class_name: Address

  has_and_belongs_to_many :skills
  accepts_nested_attributes_for :skills

  def special_skills
    skills.select(&:unpromoted)
  end

  attr_accessor :has_family_member
  validates :family_member, presence: true, if: ->(o) { o.family_member? }

  has_and_belongs_to_many :libraries
  accepts_nested_attributes_for :libraries

  enum class_status: %i(Undergraduate Graduate)
  enum graduation_year: (2016..2020).map { |year| ["#{year}_dec".intern, "#{year}_may".intern] }.flatten
end
