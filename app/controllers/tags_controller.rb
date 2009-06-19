class TagsController < ApplicationController
  def suggest
    keywords = params[:input].to_s.downcase.strip.split(/\s+/)
    firstwords = keywords[0, keywords.length - 1] || []
    lastword = keywords.last || ''
    suggestions = Tag.suggest(lastword)

    response = {
      :results => suggestions.map do |t|
        next if keywords.include? t['name']

        { :id => t['name'],
          :value => (firstwords + [t['name']]).join(' '),
          :info => "#{t['name']} (#{t['count']})" }
      end.compact
    }

    render_data response
  end
end
