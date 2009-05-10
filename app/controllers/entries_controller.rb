class EntriesController < ApplicationController
  before_filter :strip_user_input

  def index
    if params[:tag]
      @entries = Entry.find_by_tag(current_user_id, params[:tag])
    else
      @entries = Entry.find_all_by_user_id(current_user_id)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entries }
    end
  end

  # GET /entries/1
  # GET /entries/1.xml
  def show
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @entry }
    end
  end

  # GET /entries/new
  # GET /entries/new.xml
  def new
    @entry = Entry.new
    @entry.user_id = current_user_id

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @entry }
    end
  end

  # GET /entries/1/edit
  def edit
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
  end

  # POST /entries
  # POST /entries.xml
  def create
    @entry = Entry.new(params[:entry])
    @entry.user_id = current_user_id

    respond_to do |format|
      if @entry.save
        flash[:notice] = 'Entry was successfully created.'
        format.html { redirect_to(@entry) }
        format.xml  { render :xml => @entry, :status => :created, :location => @entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /entries/1
  # PUT /entries/1.xml
  def update
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })

    respond_to do |format|
      if @entry.update_attributes(params[:entry])
        flash[:notice] = 'Entry was successfully updated.'
        format.html { redirect_to(@entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1
  # DELETE /entries/1.xml
  def destroy
    @entry = Entry.find(params[:id], :conditions => { :user_id => current_user_id })
    @entry.destroy

    respond_to do |format|
      format.html { redirect_to(entries_url) }
      format.xml  { head :ok }
    end
  end

private

  def strip_user_input
    params[:entry].andand.delete :user
    params[:entry].andand.delete :user_id
  end
end
