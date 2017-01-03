require_relative '../seeds'

Prospect.delete_all
Skill.where( promoted: false ).delete_all
700.times do
  hash = {
    directory_id: Faker::Internet.email.split('@').first,
    email: Faker::Internet.email,
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    major: Faker::Educator.course, 
    in_federal_study: [true, false].sample
  }

  prospect = Prospect.new(hash)
  prospect.enumerations << Enumeration.active_graduation_years.sample(1)
  prospect.enumerations << Enumeration.active_class_statuses.sample(1)
  prospect.enumerations <<  Enumeration.active_semesters.sample(1)
  prospect.enumerations <<  Enumeration.active_libraries.sample(3)

  prospect.local_address.street_address_1 = Faker::Address.street_address
  prospect.local_address.city = Faker::Address.city
  prospect.local_address.postal_code = Faker::Address.postcode

  if [true, false].sample
    prospect.addresses << Address.new(address_type: 'permanent', street_address_1: Faker::Address.street_address,
                                      city: Faker::Address.city, postal_code: Faker::Address.postcode)
  end

  prospect.skills = Skill.promoted.sample(rand(1..Skill.promoted.count))

  [Skill.new(name: Faker::Music.instrument), Skill.new(name: Faker::Music.instrument), Skill.new(name: Faker::Music.instrument)].sample(rand(0..3)).each do |s|
    prospect.skills << s
  end

  rand(0..3).times do
    prospect.work_experiences << WorkExperience.new(name: Faker::Company.name, position_title: Faker::Name.title, location: Faker::LordOfTheRings.location, dates_of_employment: Faker::Date.backward(rand(0..1_000_000)),
                                                    duties: Faker::Lorem.words(rand(0..10)).join("\n"), library_related: [true, false].sample)
  end

  prospect.available_hours_per_week = rand(0..40)

  dts = []
  rand(prospect.available_hours_per_week..168).times do
    dts << "#{rand(0..6)}-#{rand(0..23)}"
  end

  prospect.day_times = dts.uniq
  prospect.user_confirmation = true
  prospect.user_signature = Faker::Name.name

  if [true, false].sample
    prospect.resume = Resume.new(file: File.new('test/fixtures/resume.pdf', 'r'))
  end

  prospect.save
end
