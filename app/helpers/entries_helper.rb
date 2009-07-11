module EntriesHelper
  def toggle_entries_sort_link
    if params[:order] == 'created'
      link_to 'Created', params.merge(:order => 'updated')
    else
      link_to 'Last&nbsp;Update', params.merge(:order => 'created')
    end
  end

  def entries_time_show(entry)
    if params[:order] == 'created'
      pretty_timedate(entry.created_at)
    else
      pretty_timedate(entry.updated_at)
    end
  end
end
