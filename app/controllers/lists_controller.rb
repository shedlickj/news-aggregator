class ListsController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /lists
  # GET /lists.xml
  def index
    #@lists = List.all
    @lists = current_user.lists
    @feeds = current_user.feeds

    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  # GET /lists/1
  # GET /lists/1.xml
  def show
    @list = List.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /lists/new
  # GET /lists/new.xml
  def new
    @list = List.new
    @feeds = current_user.feeds

    respond_to do |format|
      format.html # new.html.erb
      format.js {render :layout => false}
    end
  end

  # GET /lists/1/edit
  def edit
    @list = List.find(params[:id])
    @feeds = current_user.feeds
    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.js {render :layout => false}
    end
  end

  # POST /lists
  # POST /lists.xml
  def create
    @list = List.new(params[:list])
    @list.feeds_by_id = ''
    @list.user_id = current_user.id
    
    @lists = current_user.lists
    @feeds = current_user.feeds

    respond_to do |format|
      if @list.save
        format.html { redirect_to(@list, :notice => 'List was successfully created.') }
        format.xml  { render :xml => @list, :status => :created, :location => @list }
        format.js {render :layout => false}
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
        format.js {render :layout => false}
      end
    end
  end

  # PUT /lists/1
  # PUT /lists/1.xml
  def update
    @list = List.find(params[:id])
    
    @lists = current_user.lists
    @feeds = current_user.feeds
    
    # Case where feed is dropped
    puts params[:id]
    if(params[:feed_title]!=nil || params[:feed_id]!=nil)
      if(params[:feed_title]==nil)
        params[:feed_title] = Feed.find(params[:feed_id]).title
      end
      respond_to do |format|
        if(@list.add_feed(@list.id,params[:feed_title]))
          format.html { redirect_to(@list, :notice => 'List was successfully updated.') }
          format.xml  { head :ok }
          format.js {render :layout => false}
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
          format.js {render :layout => false}
        end
      end
    # Case where list is updated
    else
      @list.name = params[:list][:name]
      puts "params!!!!!!!"
      puts params[:list][:name]
      puts @list.convert_titles_to_string(params[:feeds])
      @list.feeds_by_id = @list.convert_titles_to_string(params[:feeds])
      respond_to do |format|
        if @list.save
          flash[:notice] = "List successfully updated"
          format.html { redirect_to(@list, :notice => 'List was successfully updated.') }
          format.xml  { head :ok }
          format.js {render :layout => false}
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @list.errors, :status => :unprocessable_entity }
          format.js {render :layout => false}
        end
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.xml
  def destroy
    @list = List.find(params[:id])
    @list.destroy
    flash[:notice] = "List successfully deleted"
    
    @lists = current_user.lists
    @feeds = current_user.feeds

    respond_to do |format|
      format.html { redirect_to(lists_url) }
      format.xml  { head :ok }
      format.js {render :layout => false}
    end
  end
end
