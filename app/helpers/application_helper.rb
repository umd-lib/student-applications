module ApplicationHelper
  # takes an 24 hour integer and formcats it into "HHam/pm".
  # like 13 => 1pm
  def hour_integer_to_humanized(time)
    Time.strptime(time.to_s, '%H').strftime('%l%P')
  end

  # take a time and returns string that
  # represents a one hour time range
  def hour_integer_to_range(time)
    startt = Time.strptime(time.to_s, '%H').strftime('%l-')
    endt = Time.strptime((time + 1).to_s, '%H').strftime('%l:%M %P')
    "#{startt}#{endt}"
  end

  # this returns the css class used in the cell of the avail table
  def avail_table_cell_status(form, value)
    form.object.day_times.include?(value) ? 'success' : 'warning'
  end

  def availablity_table(form)
    thead = content_tag(:thead) do
      content_tag(:tr) do
        concat content_tag(:th, '', class: 'time-label')
        AvailableTime.days.keys.collect { |d| concat content_tag(:th, d.capitalize) }
      end
    end

    tbody = content_tag :tbody do
      (0..23).collect do |hour|
        concat(content_tag(:tr, class: 'table-active') do
          concat(content_tag(:td, class: 'time-label') do
            content_tag(:span) { hour_integer_to_humanized(hour) }
          end)
          AvailableTime.days.collect do |day|
            concat(
              form.input(:day_times, include_hidden: false, label: false, wrapper: false) do
                form.collection_check_boxes :day_times, ["#{day.last}-#{hour}"],
                                            :to_s, :to_s, include_hidden: false, multiple: true do |cb|
                  content_tag(:td, class: avail_table_cell_status(form, cb.object).to_s) do
                    cb.label { cb.check_box }
                  end
                end
              end
            )
          end
        end)
      end
    end
    content_tag(:table, class: "table table-bordered #{@prospect.current_step}-availability-table", id: 'availability-table') { thead.concat(tbody) }
  end

  def prospect_row_show_link(prospect)
    link_to(prospect) do
      "<i class='glyphicon glyphicon-eye-open'/>".html_safe
    end
  end
end
