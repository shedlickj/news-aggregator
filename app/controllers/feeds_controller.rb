class FeedsController < ApplicationController
  #This is a virtual comment manager. There is no user detection, no session
  before_filter :load_post
 
  #This is our entry point, I'm just going to display a factice post to comment
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
    respond_to do |format|
      format.html { redirect_to feeds_path() }
      format.js {render :layout => false}
    end
  end
 
  #This is not a "normal" update, I'll use this one to add points to the comment
  def update
    @feed = Feed.find(params[:id])
    @feed.save
    @feeds = Feed.all
 
    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.js {render :layout => false}
    end
  end
 
  def destroy
    @feed = Feed.find(params[:id])
    @feed.destroy
 
    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.js {render :layout => false}
    end
  end
 
  protected
 
  def load_post
   @post = "This is a factice post, I hope you like it. Just comment on the bottom!"
  end
end
