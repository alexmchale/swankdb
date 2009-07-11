class EntriesController < ApplicationController
  ENTRIES_PER_LOAD = 50

  before_filter :authenticate_user_account
  before_filter :strip_user_input

  def index
    @description = []
    @description << "tagged #{params[:tag].downcase}" unless params[:tag].blank?
    @description << "with #{params[:with]}" unless params[:with].blank?
    @description << "include &#147;#{params[:keywords]}&#148;" unless params[:keywords].blank?
    @description = @description.join(', ')

    @conditions = Entry.build_search_conditions :user_id => current_user_id,
                                                :tag => params[:tag],
                                                :with => params[:with],
                                                :keywords => params[:keywords]

    @entries_count = Entry.count(:conditions => @conditions)

    @results_only = true if params[:offset]
    @params = params.to_url

    order = 'entries.%s_at DESC' % (params[:order] == 'created' ? 'created' : 'updated')

    @entries = Entry.find(:all, :conditions => @conditions, :order => order, :limit => ENTRIES_PER_LOAD, :offset => params[:offset].to_i)

    render :layout => false if @results_only
  end

  def show
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
  end

  def new
    @entry = Entry.new
    @entry.user_id = current_user_id
  end

  def edit
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
  end

  def create
    @entry = Entry.new(params[:entry])
    @entry.user_id = current_user_id
    @entry.tags = Entry.split_tags(params[:entry_tags]).join(' ')

    if @entry.save
      flash[:notice] = 'Entry was successfully created.'
      redirect_to(@entry)
    else
      render :action => "new"
    end
  end

  def update
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
    @entry.tags = Entry.split_tags(params[:entry_tags]).join(' ')

    if @entry.update_attributes(params[:entry])
      flash[:notice] = 'Entry was successfully updated.'
      redirect_to(@entry)
    else
      render :action => "edit"
    end
  end

  def destroy
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
    @entry.destroy

    redirect_to(entries_url)
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

private

  def strip_user_input
    params[:entry].andand.delete :user
    params[:entry].andand.delete :user_id
  end
end
