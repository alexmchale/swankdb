# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def link_entry_tags(entry, options = {})
    entry.tags_array.map do |tag|
      link_to raw(tag),
              { :controller => :entries, :action => :index, :tag => tag },
              :class => options[:class].to_s
    end.join ' '
  end

  def nbsp(s)
    raw s.to_s.gsub(/\s/, '&nbsp;')
  end

  def nocrlf(s)
    raw s.to_s.gsub(/[\r\n]/, '')
  end

  def pretty_timedate(time)
    now = Time.now
    delta = now - time

    [ :second, :minute, :hour, :day, :week, :month, :year ].inject('') do |str, scale|
      scale_seconds = 1.send(scale)
      break str if delta < scale_seconds
      delta_in_scale = (delta / scale_seconds).to_i
      plural = ('s' unless delta_in_scale == 1).to_s
      raw "%d&nbsp;%s%s" % [ delta_in_scale, scale, plural ]
    end
  end

  def pretty_datetime(time)
    local = ActiveSupport::TimeZone['Central Time (US & Canada)'].utc_to_local(time)
    local.strftime("%B %d, %Y at %I:%M%p").gsub(/ 0/, ' ')
  end

  def separator
    raw '<div style="clear: both; margin: 0px; padding-top: 1em; padding-bottom: 1em"></div>'
  end

  def h1(s)
    raw "<h1>%s</h1>" % h(s)
  end

  def h2(s)
    raw "<h2>%s</h2>" % h(s)
  end

  def h3(s)
    raw "<h3>%s</h3>" % h(s)
  end

  def destroy_entry_link(entry, htmloptions = {})
    htmloptions[:class] = htmloptions[:class].to_s + ' ' + 'destroy_link'
    htmloptions[:method] = :delete
    htmloptions[:confirm] = 'Are you sure you want to destroy this entry?'
    link_to 'Destroy', entry_path(entry), htmloptions
  end

  def email_entry_link(entry, htmloptions = {})
    htmloptions[:class] = htmloptions[:class].to_s + ' ' + 'email_link'
    link_to raw('&nbsp;Email&nbsp;'), url_for(:controller => :entries, :action => :email, :id => entry.id), htmloptions
  end

  def edit_entry_link(entry, htmloptions = {})
    htmloptions[:class] = htmloptions[:class].to_s + ' ' + 'edit_link'
    link_to raw('&nbsp;Edit&nbsp;'), edit_entry_path(entry), htmloptions
  end

  def view_entry_link(entry, htmloptions = {})
    htmloptions[:class] = htmloptions[:class].to_s + ' ' + 'view_link'
    link_to raw('&nbsp;View&nbsp;'), entry, htmloptions
  end

  def cancel_link(htmloptions = {})
    htmloptions[:class] = htmloptions[:class].to_s + ' ' + 'cancel_link'
    link_to raw('Cancel'), request.referrer, htmloptions
  end

  def submit_link(verb)
    '<input type="submit" style="display: none">'.html_safe +
    link_to(raw(verb), "javascript:$('div.page_content form').submit()", :class => 'save_link')
  end

  def build_host_prefix(protocol, host, port)
    default_port = (protocol == 'https://') ? 443 : 80
    port = (port == default_port) ? '' : ":#{port}"

    "%s%s%s" % [ protocol, host, port ]
  end

  def form_errors(form)
    if form.object.errors.present?
      raw <<-HTML
        <div>
          <h1>ERRORS</h1>
          <div>#{ h f.object.errors.full_messages }</div>
        </div>
      HTML
    end
  end
end
