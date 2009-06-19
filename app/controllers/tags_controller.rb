class TagsController < ApplicationController
  def suggest
    keywords = params[:input].to_s.strip.split(/\s+/)
    firstwords = keywords[0, keywords.length - 1] || []
    lastword = keywords.last || ''
    suggestions = Tag.suggest(lastword)

    response = {
      :results => suggestions.map do |t|
        { :id => t['name'],
          :value => (firstwords + [t['name']]).join(' '),
          :info => "#{t['name']} (#{t['count']})" }
      end
    }

    render_data response
  end
end
