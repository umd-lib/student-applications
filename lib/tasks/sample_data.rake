require 'prawn'

namespace :db do
  desc 'Drop, create, migrate, seed and populate sample data'
  task reset_with_sample_data: [:drop, :create, :migrate, :seed, :populate_sample_data] do
    puts 'Ready to go!'
  end

  desc 'Populates the database with sample data'


  task populate_sample_data: :environment do
    @all_available_times = []
    (0..6).each do |day|
      (0..23).each do |hour|
        @all_available_times << "#{day}-#{hour}"
      end
    end

    700.times do |index|
      prospect = create_prospect

      begin
        prospect.save
      rescue ActiveRecord::RecordNotUnique
        prospect.directory_id = "#{prospect.directory_id}#{index}"
        prospect.save
      end
    end
  end

  def create_prospect
    prospect = create_initial_prospect

    prospect.addresses = [create_address('local')]
    prospect.addresses << create_address('permanent') if rand > 0.50

    prospect.phone_numbers = [create_phone_number('local')]
    prospect.phone_numbers << create_phone_number('cell') if rand > 0.25
    prospect.phone_numbers << create_phone_number('other') if rand > 0.90

    prospect.enumerations << Enumeration.active_class_statuses.sample
    prospect.enumerations << Enumeration.active_graduation_years.sample
    prospect.enumerations << create_preferred_libraries
    prospect.enumerations << create_how_did_you_hear_about_us

    num_work_experiences = rand(4)
    work_experiences = []
    (0..num_work_experiences).each do |i|
      work_experiences << create_work_experience
    end
    prospect.work_experiences << work_experiences

    prospect.skills = Skill.promoted.sample(rand(1..Skill.promoted.count))

    if rand > 0.90
      (0..rand(4)).each do
        prospect.skills << Skill.new(name: Faker::Job.key_skill)
      end
    end

    available_hours = rand(167)+1
    available_times = @all_available_times.sample(available_hours)
    prospect.day_times = available_times
    prospect.available_hours_per_week = available_times.size

    prospect.additional_comments = Faker::Lorem.sentences(number: rand(3)).join("\n")

    prospect.user_signature = "#{prospect.first_name} #{prospect.last_name}"
    prospect.user_confirmation = true

    if [true, false].sample
        create_resume(prospect)
    end

    prospect
  end

  def create_resume(prospect)
    tempfile = Tempfile.new(['test', '.pdf'])
    begin
      pdf = Prawn::Document.new
      pdf.text "#{prospect.first_name} #{prospect.last_name}\n\n"
      pdf.text Faker::Lorem.sentences(number: rand(0..10)).join("\n")
      pdf.render_file tempfile.path
      prospect.resume = Resume.new(file: File.new(tempfile.path))
    ensure
      tempfile.close
      tempfile.unlink
    end
  end

  def create_initial_prospect
    first_name = Faker::Name.first_name
    first_initial = first_name[0,1].downcase
    last_name = Faker::Name.last_name
    directory_id = "#{first_initial}#{last_name.downcase}"
    email = Faker::Internet.safe_email(name: "#{first_initial}#{last_name.downcase}")
    semester = Enumeration.active_semesters.sample
    in_federal_study = Faker::Boolean.boolean

    prospect_hash = {
      directory_id: directory_id,
      first_name: first_name,
      last_name: last_name,
      email: email,
      semester: semester,
      in_federal_study: in_federal_study,
      major: Faker::Educator.course
    }

    prospect = Prospect.new(prospect_hash)
  end

  def create_address(address_type)
    address = Address.new({
      street_address_1: Faker::Address.street_address,
      city: Faker::Address.community,
      postal_code: Faker::Address.zip_code,
      address_type: address_type
    })
    address.street_address_2 = Faker::Address.secondary_address if rand > 0.75
    address
  end

  def create_phone_number(phone_type)
    PhoneNumber.new({
      phone_type: phone_type,
      number: Faker::PhoneNumber.phone_number
    })
  end

  def create_preferred_libraries()
    return [] if rand < 0.25
    libraries = Enumeration.active_libraries
    libraries.sample(rand(libraries.size))
  end

  def create_how_did_you_hear_about_us
    return [] if rand < 0.25
    Enumeration.active_how_did_you_hear_about_us.sample
  end

  def create_work_experience()
    date_formats = ["%m/%d/%Y", "%F", "%b %d, %Y"]

    date_format = date_formats.sample
    start_date = Faker::Date.between(from: '2014-01-01', to: Date.today)
    end_date = Faker::Date.between(from: start_date, to: Date.today)

    WorkExperience.new({
      name: "#{Faker::Company.name} #{Faker::Company.suffix}",
      dates_of_employment: "#{start_date.strftime(date_format)} - #{end_date.strftime(date_format)}",
      location: "#{Faker::Address.community}, #{Faker::Address.state_abbr}",
      position_title: Faker::Job.title,
      duties: Faker::Lorem.sentences(number: rand(10)).join("\n"),
      library_related: Faker::Boolean.boolean
    })
  end
end
