require 'feed_tools'
require 'will_paginate'
require 'chronic'
#require 'net/http'
#require 'cgi'
require 'nokogiri'
require 'mechanize'

class RssEntriesController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /rss_entries
  # GET /rss_entries.xml
  def index
    #@feeds = Feed.all
    #@lists = List.all
    #@rss_entry = RssEntry.first
    @feeds = current_user.feeds
    @lists = current_user.lists
    puts "current user:"
    puts current_user.id
    #if(params[:commit] == "Search")
    #  params[:view] = "normal" unless params[:features].include?("hidden")
    #else
    if(params[:dataset] == nil && params[:list_id] == nil && params[:view] == nil && params[:q] != nil)
#      if(params[:q]==nil)
#        params[:q] = cookies[:q]
#        params[:start_on] = cookies[:start_on]
#        params[:end_on] = cookies[:end_on]
#        params[:features] = cookies[:features]
#        params[:sources] = cookies[:sources]
#      else
#        cookies[:q] = params[:q]
#        cookies[:start_on] = params[:start_on]
#        cookies[:end_on] = params[:end_on]
#        cookies[:features] = params[:features]
#        cookies[:sources] = params[:sources]
#      end
      search_request = true
    elsif(params[:dataset] != nil)
      cookies[:dataset] = params[:dataset]
      clear_search_cookies
    elsif(params[:list_id] != nil)
      cookies[:list] = params[:list_id]
      clear_search_cookies
    elsif(params[:view] != nil)
      cookies[:view] = params[:view]
      clear_search_cookies
    end
    params[:dataset] ||= cookies[:dataset] ||= "newsfeed"
    params[:view] ||= cookies[:view] ||= "normal" unless search_request
    
    list_match = false
    iter = 1
    @lists.each{|list|
      if(list.id == cookies[:list].to_i)
        list_match = true 
        @active_list = iter
      end
      iter += 1 }
    cookies[:list] = '0' if(!list_match)
    @active_list = 0 if(!@active_list)
    
    find_and_show_entries(search_request)
  end
  
  def clear_search_cookies
    cookies[:q] = nil
    cookies[:start_on] = nil
    cookies[:end_on] = nil
    cookies[:features] = nil
    cookies[:sources] = nil
  end
  
    # GET /rss_entries/1/edit
    # This method is used to change the state of favorite and hidden
  def edit
    find_and_show_entries(false)
  end
  
  # PUT /rss_entries/1
  # PUT /rss_entries/1.xml
  def update
    @article = Article.find(params[:id])
    if(params[:task] == 'favorite')
      @article.favorite = !@article.favorite
    elsif(params[:task] == 'hide')
      @article.hidden = !@article.hidden
    end
    @article.save!
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
    #"score, published DESC"
    "score"
    #"created_at DESC"
  end
  
  private
  
  def find_and_show_entries(search_request)
    # if not search
    puts "search:"
    puts search_request
    if(!search_request)
      conditions = ""
      if(cookies[:list] != nil && cookies[:list] != '0')
        list = List.find(cookies[:list])
        list.get_feeds(list.id).each{ |feed_id|
          feed = Feed.find(feed_id)
          if (conditions.length==0) then conditions = "(rss_entries.source = '#{feed.title.gsub(/[']/, '')}')"
          else conditions += " OR (rss_entries.source = '#{feed.title.gsub(/[']/, '')}')"
          end
        }
        if (conditions.length>0) then conditions = "(" + conditions + ")"
        end
      end
      if(params[:view] == 'all')
        #do nothing
      elsif(params[:view] == 'normal')
        if (conditions.length==0) then conditions = "(articles.hidden = 'f')"
        else conditions += " AND (articles.hidden = 'f')"
        end
      elsif(params[:view] == 'favorite')
        if (conditions.length==0) then conditions = "(articles.favorite = 't')"
        else conditions += " AND (articles.favorite = 't')"
        end
      elsif(params[:view] == 'hidden')
        if (conditions.length==0) then conditions = "(articles.hidden = 't')"
        else conditions += " AND (articles.hidden = 't')"
        end
      end
      
      puts "Conditions:"
      puts conditions
    
      # Pick the set of articles to display
      if(conditions.length != 0)
        conditions += " AND "
      end
    
      if(params[:dataset] == 'newsfeed')
        puts conditions + "(articles.cluster_follower = 'f')"
        articles = Article.find(:all, :joins => :rss_entry, :conditions => [conditions + "(articles.cluster_follower = 'f') AND (articles.user_id = #{current_user.id})"])
        articles.sort! { |a,b| a.score <=> b.score }
      elsif(params[:dataset] == 'livefeed')
        articles = Article.find(:all, :joins => :rss_entry, :conditions => [conditions + "(articles.user_id = #{current_user.id})"])
        articles = articles.select{|some_article| (Time.now - some_article.rss_entry.published)/(60*60*24) < 2 }
        articles.sort! { |a,b| b.rss_entry.published <=> a.rss_entry.published }
      elsif(params[:dataset] == 'toparticles')
        articles_temp = Article.find(:all, :joins => :rss_entry, :conditions => [conditions + "(articles.cluster != 'nil' AND articles.cluster != '') AND (articles.cluster_follower = 'f') AND (articles.user_id = #{current_user.id})"])
        #articles_temp = articles_temp.select{|article| article.cluster != nil && article.cluster_follower == false}
        clusters = []
        articles_temp.each{|a| clusters << Cluster.find(a.cluster)}
        clusters.sort! { |a,b| a.score <=> b.score }
        articles = []
        clusters.each{|c| articles << c.get_leader(c)}
        #articles.sort! { |a,b| b.rss_entry.published <=> a.rss_entry.published }
      end
     
      @num_of_articles = articles.size
      @articles = articles.paginate(
      :page => params[:page],
      :per_page => 15)
    else
      @articles = current_user.articles.paginate(:all, :joins => :rss_entry,
      :order => order_from_params,
      :page => params[:page],
      :per_page => 15,
      :conditions => search_conditions)
      @num_of_articles = 0
    end
    
    @start_article_num = ((params[:page] || 1).to_i-1)*15 + 1
    @end_article_num = ((params[:page] || 1).to_i)*15
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rss_entries }
      format.js { render :layout => false }
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
            strings << "(articles.#{feature} = 't')"
          end
         }
        params[:sources].each{ |source|
          @feeds.each{ |feed|
            if(feed.title == source)
              if str_src.length==0
                str_src = "(rss_entries.source = '#{source.gsub(/[']/, '')}')"
              else
                str_src += " OR (rss_entries.source = '#{source.gsub(/[']/, '')}')"
              end
            end
          }
        }
        strings << "(#{str_OR})" << "(#{str_src})"
      end
      if cond_params[:start_on] && cond_params[:end_on]
        strings << " rss_entries.published between :start_on and :end_on"
      elsif cond_params[:start_on]
        strings << " rss_entries.published >= :start_on"
      elsif cond_params[:end_on]
        strings << " rss_entries.published <= :end_on"
      end
    end
    return cond_strings.any? ? [ cond_strings.join(' AND '), cond_params ] : nil
    #return cond_strings.join(' AND ')
  end
end
