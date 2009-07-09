class EntriesController < ApplicationController
  before_filter :authenticate_user_account
  before_filter :strip_user_input

  def index
    @description = []
    @description << "tagged #{params[:tag].downcase}" unless params[:tag].blank?
    @description << "with #{params[:with]}" unless params[:with].blank?
    @description << "include \"#{params[:keywords]}\"" unless params[:keywords].blank?
    @description = @description.join(', ')

    @entries = Entry.search :user_id => current_user_id,
                            :tag => params[:tag],
                            :with => params[:with],
                            :keywords => params[:keywords],
                            :order => 'updated_at DESC'
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
    @entry.set_tags_from_string params[:entry_tags]

    if @entry.save
      flash[:notice] = 'Entry was successfully created.'
      redirect_to(@entry)
    else
      render :action => "new"
    end
  end

  def update
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
    @entry.set_tags_from_string params[:entry_tags]

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

private

  def strip_user_input
    params[:entry].andand.delete :user
    params[:entry].andand.delete :user_id
  end
end
