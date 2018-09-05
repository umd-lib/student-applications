# This is a model for a application
# It includes the steps that are used to submit one
# rubocop:disable Rails/HasAndBelongsToMany
# rubocop:disable Metrics/ClassLength
class Prospect < ApplicationRecord
  include Walkable

  belongs_to :resume
  after_initialize :after_initialize

  has_and_belongs_to_many :enumerations, join_table: 'prospects_enumerations'

  def self.active
    where(suppressed: false)
  end

  # this makes sure we have a local address and contact phone number
  def after_initialize
    local_address unless persisted? # we call this to make sure we have one.
    contact_phone unless persisted?
    if semester
      enumerations << semester
    else
      @semester = enumerations.find { |e| e['list'] == 'semester' }
    end
  end

  # Custom Validations
  validate :must_have_class_status, :must_have_graduation_year, :must_have_semester, :only_one_id_per_semester

  # rubocop:disable Style/GuardClause, Metrics/LineLength, Rails/OutputSafety
  def only_one_id_per_semester
    if current_step == 'id_and_semester' && !persisted? && semester
      if Prospect.joins(:enumerations).where(suppressed: false, directory_id: directory_id, enumerations: { id: semester.id }).exists?
        errors.add(:semester, "Please note that this directory ID has already submitted an application. You are only allowed one application submission per semester. If you need to edit your submission please contact Lisa Warner at <a href='tel:3014059245'>301-405-9245</a> or <a href='mailto:lwarner@umd.edu'>lwarner@umd.edu</a> for assistance.".html_safe)
      end
    end
  end
  # rubocop:enable Metrics/LineLength, Rails/OutputSafety

  def must_have_class_status
    if current_step == 'contact_info' && class_status.nil?
      errors.add(:class_status, 'You must have one ( and only one ) Class Status selected.')
    end
  end

  def must_have_graduation_year
    if current_step == 'contact_info' && graduation_year.nil?
      errors.add(:graduation_year, 'You must have one ( and only one ) Graduation Year selected.')
    end
  end

  def must_have_semester
    if current_step == 'id_and_semester' && semester.nil?
      errors.add(:semester, 'Please indicate which semester you are applying for.')
    end
  end
  # rubocop:enable Style/GuardClause, Metrics/LineLength

  attr_accessor :class_status
  def class_status
    enumerations.find { |e| e['list'] == 'class_status' }
  end

  attr_accessor :graduation_year
  def graduation_year
    enumerations.find { |e| e['list'] == 'graduation_year' }
  end

  attr_accessor :semester
  # def semester
  #  enumerations.find { |e| e['list'] == Enumeration.lists['semester'] }
  # end

  def semester=(value) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    return if value.nil? || value.blank?

    current = @semester.nil? ? enumerations.find { |e| e['list'] == 'semester' } : @semester

    enum =  value.is_a?(Enumeration) ? value : Enumeration.active_semesters.find { |e| e['value'] == value }
    raise ArgumentError, "#{value} is not a valid semester value ( #{Enumeration.active_semesters.map(&:value).join(',')} )" unless enum

    enumerations.delete(current) unless current.nil?
    enumerations << enum
    @semester = enum
  end

  attr_accessor :libraries
  def libraries
    enumerations.select { |e| e['list'] == 'library' } || []
  end

  attr_accessor :how_did_you_hear_about_us
  def how_did_you_hear_about_us
    enumerations.find { |e| e['list'] == 'how_did_you_hear_about_us' } || []
  end

  # this validates if the user has clicked "All information is correct" on last
  # step
  validates :user_confirmation, acceptance: true, if: ->(p) { p.last_step? }
  validates :user_signature, presence: true, if: ->(p) { p.last_step? }

  # directory_id and semester
  %i[directory_id].each do |attr|
    validates attr, presence: true, if: ->(p) { p.current_step == 'id_and_semester' }
  end

  # these are the validations for the contact_information step
  validates :in_federal_study, inclusion: { in: [true, false], if: ->(p) { p.current_step == 'contact_info' } }
  %i[directory_id first_name last_name email].each do |attr|
    validates attr, presence: true, if: ->(p) { p.current_step == 'contact_info' }
  end

  has_many :work_experiences, dependent: :destroy
  accepts_nested_attributes_for :work_experiences, allow_destroy: true

  has_many :available_times, dependent: :destroy
  accepts_nested_attributes_for :available_times, allow_destroy: true

  # the number of available hours per week should =< number of available_times
  validate :available_hours_per_week_gt_available_times
  validates :available_hours_per_week, numericality: { greater_than_or_equal_to: 0 }

  # rubocop:disable Style/GuardClause
  def available_hours_per_week_gt_available_times
    if available_hours_per_week > available_times.size
      errors.add(:available_hours_per_week, "can't be greater than the number of available times provided.")
    end
  end
  # rubocop:enable Style/GuardClause

  def name
    "#{last_name}, #{first_name}"
  end

  # this is a way of feeding day-times into the prospect and have them stored
  # in
  attr_accessor :day_times
  def day_times
    @day_times ||= available_times.map(&:day_time)
    @day_times
  end

  def day_times=(dts)
    available_times.each(&:mark_for_destruction)
    dts.each do |dt|
      day, time = dt.split('-').map(&:to_i)
      available_times.build(day: day, time: time)
    end
    @day_times = available_times.map { |at| at.day_time unless at.marked_for_destruction? }.compact
  end

  has_many :phone_numbers, inverse_of: :prospect, dependent: :destroy
  accepts_nested_attributes_for :phone_numbers, allow_destroy: true

  # by default we want to have one contact_phone, either a new one we've built
  # or an phone number that has been provided
  def contact_phone_with_default
    phone_numbers.first || phone_numbers.build
  end
  has_one :contact_phone, class_name: PhoneNumber
  accepts_nested_attributes_for :contact_phone, allow_destroy: true

  def contact_phone
    super || contact_phone_with_default
  end
  validates :contact_phone, presence: true, if: ->(o) { o.current_step == 'contact_info' }
  validates_associated :contact_phone, if: ->(o) { o.current_step == 'contact_info' }

  has_many :addresses, inverse_of: :prospect, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true
  #  validates_associated :addresses, if: ->(o) { o.current_step == "contact_info" }

  # by default we want to have one local_address, either a new one we've built
  # or an address that has been provided
  def local_address_with_default
    addresses.find(&:local?) || addresses.build(address_type: 'local')
  end

  has_one :local_address, -> { where(address_type: 'local') }, class_name: Address
  accepts_nested_attributes_for :local_address, allow_destroy: true

  def local_address
    super || local_address_with_default
  end
  validates :local_address, presence: true, if: ->(o) { o.current_step == 'contact_info' }
  validates_associated :local_address, if: ->(o) { o.current_step == 'contact_info' }

  has_one :permanent_address, -> { where(address_type: 'permanent') }, class_name: Address
  accepts_nested_attributes_for :permanent_address, allow_destroy: true

  has_and_belongs_to_many :skills, dependent: :nullify
  accepts_nested_attributes_for :skills

  def special_skills
    skills.select(&:unpromoted)
  end
end
