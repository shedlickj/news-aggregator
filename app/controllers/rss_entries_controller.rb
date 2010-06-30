require 'feed_tools'
require 'will_paginate'
require 'chronic'
require 'net/http'
require 'cgi'

class RssEntriesController < ApplicationController
  # GET /rss_entries
  # GET /rss_entries.xml
  def index
    @feeds = Feed.all
    @lists = List.all
    @rss_entry = RssEntry.first
    #if(params[:commit] == "Search")
    #  params[:view] = "normal" unless params[:features].include?("hidden")
    #else
    if(params[:list_id] != nil)
      cookies[:list] = params[:list_id]
    end
    params[:view] ||= "normal" unless params[:q] != nil
    find_and_show_entries
  end
  
    # GET /rss_entries/1/edit
    # This method is used to change the state of favorite and hidden
  def edit
    find_and_show_entries
  end
  
  # PUT /rss_entries/1
  # PUT /rss_entries/1.xml
  def update
    @rss_entry = RssEntry.find(params[:id])
    if(params[:task] == 'favorite')
      @rss_entry.favorite = !@rss_entry.favorite
    elsif(params[:task] == 'hide')
      @rss_entry.hidden = !@rss_entry.hidden
    end
    @rss_entry.save!
    redirect_to :action => 'index'
  end

#  verify :method => :post, :only => [ :destroy, :create, :update ],
#         :redirect_to => { :action => :index }

  # GET /rss_entries/1
  # GET /rss_entries/1.xml
  def show
    @rss_entry = RssEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rss_entry }
    end
  end

  # GET /rss_entries/new
  # GET /rss_entries/new.xml
  def new
    @rss_entry = RssEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rss_entry }
    end
  end

  # POST /rss_entries
  # POST /rss_entries.xml
  def create
    @rss_entry = RssEntry.new(params[:rss_entry])

    respond_to do |format|
      if @rss_entry.save
        format.html { redirect_to(@rss_entry, :notice => 'RssEntry was successfully created.') }
        format.xml  { render :xml => @rss_entry, :status => :created, :location => @rss_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rss_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rss_entries/1
  # DELETE /rss_entries/1.xml
  def destroy
#    @rss_entry = RssEntry.find(params[:id])
#    @rss_entry.destroy
#    unless params[:search].blank?
#      @rss_entries = RssEntry.paginate :page => params[:page],
#        :per_page   => 10, 
#        :order      => order_from_params,
#        :conditions => ['title like ?', "%#{params['search']}%" ] #conditions_by_like(params[:search])
#      logger.info @rss_entries.size
#    else
#      #list
#      index
#    end
#    render :partial=>'search', :layout=>false
  end
  
  def order_from_params
#    if params[:form_sort] && params[:form_sort].size > 0
#      params[:form_sort].downcase.split(",").map { |x| 
#        x.tr(" ", "_")
#      }.join(" ")
#    else
#      "username"
#    end
    "published DESC"
  end
  
  def update_articles
    Feed.all.map { |feed|
      puts "uri: " << feed.uri
      open_feed = FeedTools::Feed.open( feed.uri ) #TODO: Error checking
      open_feed.items.map { |item|
        entry = RssEntry.find_or_initialize_by_title(item.title)
        entry.source = feed.title
        entry.title = item.title
        entry.published = item.published
        entry.link = item.link
        entry.description = (item.description || "No description").gsub(/<[^>]+>/,"").squeeze(" ").strip
        entry.hidden ||= false
        entry.favorite ||= false
        store_article_text(entry)
        entry.save! #TODO: Error checking
      }
    }
    find_and_show_entries
  end
  
  def store_article_text(entry)
      entry.data = nil;
      puts "storing data"
      response = Net::HTTP.get_response(URI.parse(entry.link))
      entry.data = response
  end

  def feed_create
    @feed = Feed.new(params[:feed])
    @feeds = Feed.all
    @feed.save!
    render(:partial=>'right_bar_3', :layout=>false)
  end
  
  private
  
  def find_and_show_entries
    puts "view:"
    puts params[:view]
    # if not search
    if(params[:view] != nil)
      conditions = ""
      puts "cookie:"
      puts cookies[:list]
      if(cookies[:list] != nil && cookies[:list] != '0')
        list = List.find(cookies[:list])
        list.get_feeds(list.id).each{ |feed_id|
          feed = Feed.find(feed_id)
          if (conditions.length==0) then conditions = "(rss_entries.source = '#{feed.title}')"
          else conditions += " OR (rss_entries.source = '#{feed.title}')"
          end
        }
      end
      if(params[:view] == 'all')
        #do nothing
      elsif(params[:view] == 'normal')
        if (conditions.length==0) then conditions = "(rss_entries.hidden = 'f')"
        else conditions += " AND (rss_entries.hidden = 'f')"
        end
      elsif(params[:view] == 'favorite')
        if (conditions.length==0) then conditions = "(rss_entries.favorite = 't')"
        else conditions += " AND (rss_entries.favorite = 't')"
        end
      elsif(params[:view] == 'hidden')
        if (conditions.length==0) then conditions = "(rss_entries.hidden = 't')"
        else conditions += " AND (rss_entries.hidden = 't')"
        end
      end
    else
      conditions = search_conditions
    end
    @rss_entries = RssEntry.paginate(:all,
    :order => order_from_params,
    :page => params[:page],
    :per_page => 20,
    :conditions => conditions)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rss_entries }
      format.js {render :layout => false}
    end
  end

  def search_conditions
    cond_params = {
      :q => "%#{params[:q]}%",
      :start_on => Chronic.parse(params[:start_on]),
      :end_on => Chronic.parse(params[:end_on])
    }
    cond_strings = returning([]) do |strings|
      unless params[:features].blank? || params[:sources].blank?
        str_OR = str_src = ''
        params[:features].each{ |feature|
          if(APP_CONFIG['OR_terms'].include?(feature))
            if str_OR.length==0
              str_OR = "(LOWER(rss_entries.#{feature}) like :q)"
            else
              str_OR += " OR (LOWER(rss_entries.#{feature}) like :q)"
            end
          elsif(APP_CONFIG['AND_terms'].include?(feature))
            strings << "(rss_entries.#{feature} = 't')"
          end
         }
        params[:sources].each{ |source|
          @feeds.each{ |feed|
            if(feed.title == source)
              if str_src.length==0
                str_src = "(rss_entries.source = '#{source}')"
              else
                str_src += " OR (rss_entries.source = '#{source}')"
              end
            end
          }
        }
        strings << "(#{str_OR})" << "(#{str_src})"
      end
      if cond_params[:start_on] && cond_params[:end_on]
        strings << " rss_entries.created_at between :start_on and :end_on"
      elsif cond_params[:start_on]
        strings << " rss_entries.created_at >= :start_on"
      elsif cond_params[:end_on]
        strings << " rss_entries.created_at <= :end_on"
      end
    end
    puts cond_strings
    cond_strings.any? ? [ cond_strings.join(' AND '), cond_params ] : nil
  end
end
