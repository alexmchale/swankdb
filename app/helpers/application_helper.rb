# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_entry_tags(entry, options = {})
    entry.tags_array.map do |tag|
      link_to tag,
              { :controller => :entries, :action => :index, :tag => tag },
              :class => options[:class].to_s
    end.join ' '
  end

  def nbsp(s)
    s.to_s.gsub(/\s/, '&nbsp;')
  end

  def nocrlf(s)
    s.to_s.gsub(/[\r\n]/, '')
  end

  def pretty_timedate(time)
    now = Time.now
    delta = now - time
    result = ""

    [ :second, :minute, :hour, :day, :month, :year ].each do |scale|
      scale_seconds = 1.send(scale)
      break if delta < scale_seconds
      count = (delta / scale_seconds).to_i
      s = count != 1 ? 's' : ''
      result = "%d&nbsp;%s%s" % [ count, scale, s ]
    end

    result
  end

  def separator
    '<div style="clear: both; margin: 0px; padding-top: 1em; padding-bottom: 1em"></div>'
  end

  def h1(s)
    "<h1>%s</h1>" % [ h s ]
  end

  def h2(s)
    "<h2>%s</h2>" % [ h s ]
  end

  def h3(s)
    "<h3>%s</h3>" % [ h s ]
  end
end
