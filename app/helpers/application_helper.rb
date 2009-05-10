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
    time.strftime('%I:%M%P on  %m/ %d/%y').gsub(/(^0+)|( 0+)/, '').gsub(/\s+/, ' ').gsub(/\/\s+/, '/')
  end
end
