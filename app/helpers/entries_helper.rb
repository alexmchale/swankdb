module EntriesHelper
  MAX_ENTRY_CONTENT_SUMMARY_LENGTH = 500

  def toggle_entries_sort_link
    if params[:order] == 'created'
      link_to 'Created', params.merge(:order => 'updated')
    else
      link_to raw('Last&nbsp;Update'), params.merge(:order => 'created')
    end
  end

  def entries_time_show(entry)
    if params[:order] == 'created'
      pretty_timedate(entry.created_at)
    else
      pretty_timedate(entry.updated_at)
    end
  end

  def summarize_entry_content(entry)
    content = entry.content.to_s

    shortened = if content.length > MAX_ENTRY_CONTENT_SUMMARY_LENGTH
                  content[0, MAX_ENTRY_CONTENT_SUMMARY_LENGTH] + '&hellip;'
                else
                  content
                end

    stripped = RDiscount.new(shortened).to_html.striphtml

    lines = stripped.split(/\n+/)
    lines[0] = '<b>' + lines[0] + '</b><br>' unless lines[1].blank?
    #lines[0] = '<span class="entry_index_first_line">%s</span>' % lines[0].to_s
    raw lines.join(' ')
  end
end
