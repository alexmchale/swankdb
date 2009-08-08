class IcalController < ApplicationController
  MAX_ENTRIES = 50

  respond_to :ics

  def updated
    entries = get_entries(:updated)
    calendarize entries, :mode => :updated
  end

  def created
    entries = get_entries(:created)
    calendarize entries, :mode => :created
  end

private

  def get_entries(mode)
    order = (mode == :created) ? 'created_at DESC' : 'updated_at DESC'
    Entry.find(:all, :conditions => { :user_id => current_user_id }, :limit => MAX_ENTRIES, :order => order)
  end

  def calendarize(entries, options = {})
    mode = options[:mode] || :created

    cal = Icalendar::Calendar.new

    entries.each do |entry|
      event = Icalendar::Event.new

      stripped = RDiscount.new(entry.content.to_s).to_html.striphtml

      event.dtstart = ((mode == :created) ? entry.created_at : entry.updated_at).to_date
      event.dtstart.ical_params = { "VALUE" => "DATE" }
      event.dtend = ((mode == :created) ? entry.created_at : entry.updated_at).to_date + 1
      event.dtend.ical_params = { "VALUE" => "DATE" }
      event.summary = clean_text(stripped.split(/\n+/).first.to_s[0, 25])
      event.description = clean_text(entry.content)

      cal.add event
    end

    render :text => cal.to_ical
  end

  def clean_text(s)
    s.to_s.gsub(/[^[:print:]\n]/, '')
  end
end
