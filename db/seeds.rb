Skill.find_or_create_by(name: 'Customer Service', promoted: true)
Skill.find_or_create_by(name: 'Computer Experience', promoted: true)
Skill.find_or_create_by(name: 'Use of Office Machinery (i.e. fax, copier )', promoted: true)
Skill.find_or_create_by(name: 'Clerical Duties', promoted: true)
Skill.find_or_create_by(name: 'Foreign Languages', promoted: true)
Skill.find_or_create_by(name: 'Previous Library Experience', promoted: true)
Skill.find_or_create_by(name: 'Mathematics and Numeracy', promoted: true)
Skill.find_or_create_by(name: 'Creative', promoted: true)
Skill.find_or_create_by(name: 'Social Media', promoted: true)
Skill.find_or_create_by(name: 'Communication', promoted: true)

['A Friend/Referral', 'Library Website', 'HR Job Board', 'Careers4Terps', 'Walk-in', 'Other'].each do |term|
  Enumeration.find_or_create_by(value: term, list: Enumeration.lists['how_did_you_hear_about_us'])
end

Enumeration.find_or_create_by(value: 'Undergraduate', list: Enumeration.lists['class_status'])
Enumeration.find_or_create_by(value: 'Graduate', list: Enumeration.lists['class_status'])
(2016..2020).each_with_index do |yr, _i|
  %w(Dec May).each_with_index { |m, _ii| Enumeration.find_or_create_by(value: "#{yr} #{m}", list: Enumeration.lists['graduation_year']) }
  %w(Spring Fall).each_with_index { |s, _ii| Enumeration.find_or_create_by(value: "#{s} #{yr}", list: Enumeration.lists['semester']) }
end

['No preference', 'Art', 'Architecture', 'Chemistry', 'Engineering and Physical Sciences Library',
 'Hornbake: Special Collections/University Archives', 'Hornbake: Library Media Services', 'McKeldin',
 'MS Performing Arts Library'].each do |lib|
  Enumeration.find_or_create_by(value: lib, list: Enumeration.lists['library'])
end
