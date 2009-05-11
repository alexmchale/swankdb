# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_entry_tags(entry)
    entry.tags_list.map do |tag|
      link_to tag, :controller => :entries, :action => :index, :tag => tag
    end.join ' '
  end

  def nbsp(s)
    s.to_s.gsub(/\s/, '&nbsp;')
  end

  def pretty_timedate(time)
    now = Time.now
    delta = now - time

    if delta < 1.minute
      "%d&nbsp;seconds" % (delta / 1.second)
    elsif delta < 1.hour
      "%d&nbsp;minutes" % (delta / 1.minute)
    elsif delta < 1.day
      "%d&nbsp;hours" % (delta / 1.hour)
    elsif delta < 1.month
      "%d&nbsp;days" % (delta / 1.day)
    elsif delta < 1.year
      "%d&nbsp;months" % (delta / 1.month)
    else
      "%d&nbsp;years" % (delta / 1.year)
    end
  end

  def separator
    '<div style="clear: both; margin: 0px; padding-top: 1em; padding-bottom: 1em"></div>'
  end
end
