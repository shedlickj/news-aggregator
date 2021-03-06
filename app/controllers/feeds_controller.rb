class FeedsController < ApplicationController

  def index
    #@feeds = Feed.all
    @feeds = current_user.feeds
    respond_to do |format|
      format.html #we only respond to the html request
    end
  end
 
  def new
    @feed = Feed.new
    if !request.xhr?
      #@feeds = Feed.all
      @feeds = current_user.feeds
    end
 
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
 
  def create
    @feed = Feed.create(params[:feed])
    @feed.user_id = current_user.id
    if(@feed.save)
      flash[:notice] = "Feed successfully created"
    end
    @feeds = current_user.feeds
    respond_to do |format|
      format.html { redirect_to feeds_path() }
      format.js {render :layout => false}
    end
  end
  
    # GET /rss_entries/1
  # GET /rss_entries/1.xml
  def show
    @feed = Feed.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rss_entry }
    end
  end

 
   # GET /feeds/1/edit
  def edit
    @feed = Feed.find(params[:id])
    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.js {render :layout => false}
    end
  end
  
  # PUT /feeds/1
  # PUT /feeds/1.xml
  def update
    @feed = Feed.find(params[:id])
    @feeds = current_user.feeds
    if @feed.update_attributes(params[:feed])
      flash[:notice] = "Feed successfully updated"
    else
      flash[:error] = "Feed update failed"
    end
      
    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.js {render :layout => false}
    end
  end
 
  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy
    @feeds = current_user.feeds
    flash[:notice] = "Feed successfully deleted"
 
    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.js {render :layout => false}
    end
  end
end
