class FeedsController < ApplicationController

  def index
    @feeds = Feed.all
    respond_to do |format|
      format.html #we only respond to the html request
    end
  end
 
  def new
    @feed = Feed.new
    if !request.xhr?
      @feeds = Feed.all
    end
 
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
 
  def create
    @feed = Feed.create(params[:feed])
    @feeds = Feed.all
    puts @feed.errors
    if(@feed.errors.empty?)
      puts "no errors"
    end
    respond_to do |format|
      format.html { redirect_to feeds_path() }
      format.js {render :layout => false}
    end
  end
 
   # GET /feeds/1/edit
  def edit
    @feed = Feed.find(params[:id])
  end
  
  # PUT /feeds/1
  # PUT /feeds/1.xml
  def update
    @feed = Feed.find(params[:id])
    if @feed.update_attributes(params[:feed])
      #show success
    else
      #show failure
    end
    @feeds = Feed.all
 
    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.js {render :layout => false}
    end
  end
 
  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy
    @feeds = Feed.all
 
    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.js {render :layout => false}
    end
  end
end
