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
end
