module ApplicationHelper
  # take a time and returns string that
  # represents a one hour time range
  def hour_integer_to_range(time)
    startt = Time.strptime(time.to_s, '%H').strftime('%I-')
    endt = Time.strptime((time + 1).to_s, '%H').strftime('%I:%M %P')
    "#{startt}#{endt}"
  end

  def availablity_table(form)
    thead = content_tag(:thead) do
      content_tag(:tr) do
        concat content_tag(:th, '')
        AvailableTime.days.keys.collect { |d| concat content_tag(:th, d.capitalize) }
      end
    end

    tbody = content_tag :tbody do
      (0..23).collect do |hour|
        concat(content_tag(:tr, class: 'table-active') do
          concat content_tag(:td, hour_integer_to_range(hour))
          AvailableTime.days.collect do |day|
            concat(
              form.input(:day_times, include_hidden: false, label: false, wrapper: false) do
                form.collection_check_boxes :day_times, ["#{day.last}-#{hour}"],
                                            :to_s, :to_s, include_hidden: false, multiple: true do |cb|
                  content_tag(:td, class: form.object.day_times.include?(cb.object) ? 'success' : 'warning') { cb.label { cb.check_box } }
                end
              end
            )
          end
        end)
      end
    end
    content_tag(:table, class: 'table table-bordered availability-table') { thead.concat(tbody) }
  end
end
