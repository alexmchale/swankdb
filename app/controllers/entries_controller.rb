class EntriesController < ApplicationController
  ENTRIES_PER_LOAD = 50

  DOWNLOAD_MODES = [
    {
      'type'        => 'txt',
      'mime-type'   => 'text/plain',
      'description' => 'Plain Text',
      'describe'    => Proc.new {|list| list.map {|e| e.plaintext}.join("\r\n")}
    },

    {
      'type'        => 'csv',
      'mime-type'   => 'text/csv',
      'description' => 'Comma Separated Values (CSV)',
      'describe'    => Proc.new {|list| list.to_comma}
    },

    {
      'type'        => 'json',
      'mime-type'   => 'text/json',
      'description' => 'JavaScript Object Notation (JSON)',
      'describe'    => Proc.new {|list| list.to_json}
    },

    {
      'type'        => 'xml',
      'mime-type'   => 'text/xml',
      'description' => 'Extensible Markup Language (XML)',
      'describe'    => Proc.new {|list| list.to_xml}
    }
  ]

  before_filter :authenticate_user_account
  before_filter :strip_user_input

  def index
    # Build the array of SQL conditions for our filter.
    @conditions = Entry.build_search_conditions :user_id => current_user_id,
                                                :tag => params[:tag],
                                                :keywords => params[:keywords]

    # Assign a default tag for the quick-entry field.
    @default_tags = params[:tag].to_s.strip
    @default_tags += ' ' unless @default_tags.blank?

    # Retrieve the total number of entries that match our filter.
    @entries_count = Entry.count(:conditions => @conditions)

    # Generate a text description of our filter.
    clauses = []
    clauses << "tagged #{params[:tag].downcase}" unless params[:tag].blank?
    clauses << "include &#147;#{HTMLEntities.encode_entities params[:keywords]}&#148;" unless params[:keywords].blank?
    @description = "%d %s %s" % [
      @entries_count,
      (@entries_count != 1 ? 'entries' : 'entry'),
      clauses.to_sentence
    ]

    # Check if we're only interested in the results (if an offset is specified).
    @results_only = true if params[:offset]

    # The current request parameters are used to generate AJAX links in this page.
    @params = params.to_url

    # Default to ordering by the update timestamp, unless requested otherwise.
    order = 'entries.%s_at DESC' % (params[:order] == 'created' ? 'created' : 'updated')

    # The query parameter indicates we're only interested in the count and description.
    return render_data(:count => @entries_count, :description => @description) if params.has_key?(:query)

    # Retrieve the requested entries from the database.
    @entries = Entry.find(:all, :conditions => @conditions, :order => order, :limit => ENTRIES_PER_LOAD, :offset => params[:offset].to_i)

    # Store the current URI if this was an original request.  This is for redirects from edit pages.
    session[:last_view] = request.request_uri unless @results_only

    # Dispatch what we've found to the client.
    if params.has_key? :json
      render_data @entries
    else
      render :layout => false if @results_only
    end
  end

  def show
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })

    # Store the current URI.  This is for redirects from edit pages.
    session[:last_view] = request.request_uri unless @results_only

    render_data(@entry) if params[:json]
  end

  def preview
    @entry = Entry.new
    @entry.content = params[:content].to_s
    @entry.tags = params[:tags].to_s
    render :partial => 'display'
  end

  def new
    @entry = Entry.new
    @entry.user_id = current_user_id
  end

  def edit
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
  end

  def email
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
    @user = current_user

    if request.post? && !params[:destination].blank?
      destination = params[:destination]
      subject = params[:subject].to_s

      UserEmails.deliver_entry current_user, destination, subject, @entry

      flash[:notice] = "You have successfully sent <b>#{params[:destination]}</b> this note."

      redirect_to :action => :show, :id => @entry.id
    end
  end

  def create
    @entry = Entry.new
    @entry.user_id = current_user_id
    @entry.content = params[:entry_content].to_s.strip
    @entry.tags = Entry.split_tags(params[:entry_tags]).join(' ')

    if @entry.save
      if params.has_key? :json
        render_data @entry
      elsif params[:redirect] == 'index'
        flash[:notice] = 'Entry was successfully created.'
        redirect_to(:action => :index)
      elsif params[:redirect] == 'none'
        render_data :id => @entry.id
      else
        flash[:notice] = 'Entry was successfully created.'
        redirect_to(@entry)
      end
    else
      render :action => "new"
    end
  end

  def update
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
    @entry.content = params[:entry_content].strip
    @entry.tags = Entry.split_tags(params[:entry_tags]).join(' ')

    if @entry.save && @entry.reload
      # flash[:notice] = 'Entry was successfully updated.'

      if params[:json]
        render_data @entry
      elsif session[:last_view]
        redirect_to session[:last_view]
        session.delete :last_view
      else
        redirect_to(@entry)
      end
    else
      render :action => "edit"
    end
  end

  def destroy
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })

    if @entry
      @entry.content = ''
      @entry.save
    end

    if params.has_key? :json
      render_data true
    else
      redirect_to(entries_url)
    end
  end

  def suggest_tags
    if params[:input].to_s =~ / $/
      suggestions = []
    else
      input = params[:input].to_s.split
      all_but_last = input[0, input.length - 1] || []
      last_word = input.last.to_s

      suggestions = current_user.suggest_tags(last_word).map do |tag|
        tag_count = current_user.count_tags(tag)
        newtag = (all_but_last + [tag]).join(' ')

        { :id => tag,
          :value => newtag + ' ',
          :info => "#{tag} (#{tag_count})" }
      end
    end

    render_data :results => suggestions
  end

  def download
    @show_user_menu = true
    @user = current_user
    mode = DOWNLOAD_MODES.find {|m| m['type'] == params[:mode]}

    if current_user && mode
      starting_time = Time.parse(params[:starting_at] || '01/01/2000')
      conditions = [ "updated_at > ? AND user_id = ? AND LENGTH(content) > 0", starting_time, current_user_id ]
      entries = Entry.find(:all, :conditions => conditions)

      data = mode['describe'].call(entries)
      send_data data, :type => mode['mime-type'], :disposition => 'attachment', :filename => "swankdb.#{mode['type']}"
    end
  end

private

  def strip_user_input
    params[:entry].andand.delete :user
    params[:entry].andand.delete :user_id
  end
end
