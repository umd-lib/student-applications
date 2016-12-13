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

Enumeration.find_or_create_by(value: 'Undergraduate', list: 'class_status', position: 1)
Enumeration.find_or_create_by(value: 'Graduate', list: 'class_status', position: 2)
(2016..2020).each_with_index do |yr, i|
  %w(Dec May).each_with_index { |m, ii| Enumeration.find_or_create_by(value: "#{yr} #{m}", list: 'graduation_year', position: i + ii) }
  %w(Spring Fall).each_with_index { |s, ii| Enumeration.find_or_create_by(value: "#{s} #{yr}", list: 'semester', position: i + ii) }
end

['No preference', 'Art', 'Architecture', 'Chemistry', 'Engineering and Physical Sciences Library',
 'Hornbake: Special Collections/University Archives', 'Hornbake: Library Media Services', 'McKeldin',
 'MS Performing Arts Library'].each_with_index do |lib, i|
  Enumeration.find_or_create_by(value: lib, list: 'library', position: i)
end
