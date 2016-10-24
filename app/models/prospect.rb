# This is a model for a application
# It includes the steps that are used to submit one
class Prospect < ActiveRecord::Base
  include Walkable

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

  # these are the validations for the contact_information step
  validates :in_federal_study, inclusion: { in: [true, false], if: ->(o) { o.current_step == 'contact_info' } }
  %i(directory_id first_name last_name email graduation_year).each do |attr|
    validates attr, presence: true, if: ->(o) { o.current_step == 'contact_info' }
  end

  has_many :work_experiences
  accepts_nested_attributes_for :work_experiences, allow_destroy: true

  has_many :available_times
  accepts_nested_attributes_for :available_times, allow_destroy: true

  has_many :addresses, inverse_of: :prospect
  accepts_nested_attributes_for :addresses, allow_destroy: true
  #  validates_associated :addresses, if: ->(o) { o.current_step == "contact_info" }

  # by default we want to have one local_address, either a new one we've built
  # or an address that has been provided
  def local_address_with_default
    addresses.find(&:local?) || addresses.build(address_type: 'local')
  end
  has_one :local_address, -> { where(address_type: 'local') }, class_name: Address
  alias_method_chain :local_address, :default
  validates :local_address, presence: true, if: ->(o) { o.current_step == 'contact_info' }

  has_and_belongs_to_many :skills
  accepts_nested_attributes_for :skills
  attr_accessor :skill_ids

  attr_accessor :has_family_member
  validates :family_member, presence: true, if: ->(o) { o.family_member? }

  enum class_status: %i(Undergraduate Graduate)
  enum graduation_year: (2016..2020).map { |year| ["#{year}_dec".intern, "#{year}_may".intern] }.flatten

  def self.steps
    %w(contact_info work_experience skills availability comments_confirmation)
  end

  def steps
    self.class.steps
  end
end
