require 'feed_tools'
require 'will_paginate'
require 'chronic'
#require 'net/http'
#require 'cgi'
require 'nokogiri'

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
  
  def cluster_articles(entry)
#    RssEntry.all(:conditions => "data <> ''").each {|entry|
#       find_spot_signature(entry)
#       entry.save!
#    }
#    RssEntry.all(:conditions => "spot_signature <> '' AND (rss_entries.source != 'Gizmodo')").each {|entry|
    best_similarities = 0
    best_entry = nil
    best_matches = []
    RssEntry.all(:conditions => "spot_signature <> '' AND (rss_entries.source != 'Gizmodo')").each {|compareEntry|
      if((entry.id != compareEntry.id) && (entry.link != compareEntry.link))
        similarities = 0
        matches = []
        spots = compareEntry.spot_signature.split(" || ")
        entry.spot_signature.split(" || ").each { |currSpot|
          if(spots.include?(currSpot))
            similarities+=1
            matches << currSpot
          end
        }
        if((entry.source != compareEntry.source && similarities >= 4) || (entry.source == compareEntry.source && similarities >= 10) || (entry.source != compareEntry.source && Float(similarities)/entry.spot_signature.split(" || ").length >= 0.2 && similarities >=2)|| (entry.source == compareEntry.source && Float(similarities)/entry.spot_signature.split(" || ").length >= 0.5 && similarities >=4) )
          if(similarities > best_similarities)  # closer match found
            if(compareEntry.cluster != nil)  # new match is in a cluster
              best_similarities = similarities
              best_entry = compareEntry
              best_matches = matches
            elsif(best_entry && best_entry.cluster != nil) # old match was in a cluster
              #do nothing
            else  # neither in a cluster
              best_similarities = similarities
              best_entry = compareEntry
              best_matches = matches              
            end
          end
        end
      end
      }
      if(best_similarities > 0)
        add_to_cluster(entry, best_entry, best_matches)
      end
    #}
  end
  
  def add_to_cluster(entry, compareEntry, matches)
          if(compareEntry.cluster && compareEntry.cluster != "") #If other article is clustered, add current article to that cluster
            entry.cluster = compareEntry.cluster
            if(entry.save)
              puts "added to existing cluster"
            end
            @cluster = Cluster.find(entry.cluster)
            @cluster.add_article(@cluster, matches, entry.id)
            puts @cluster.list_of_articles
          elsif(entry.cluster && entry.cluster != "")            #If article is clustered, add other article to this cluster
            compareEntry.cluster = entry.cluster
            if(entry.save)
              puts "added to existing cluster"
            end
            @cluster = Cluster.find(entry.cluster)
            @cluster.add_article(@cluster, matches, compareEntry.id)
            puts @cluster.list_of_articles
          else                                                   #Otherwise, make a new cluster
            @cluster = Cluster.new
            @cluster.list_of_articles = "#{entry.id} || #{compareEntry.id}"
            puts @cluster.list_of_articles
            @cluster.spot_matches = matches.join(' || ')
            if(@cluster.save)
              puts "new cluster"
            end
            entry.cluster = @cluster.id
            compareEntry.cluster = @cluster.id
            entry.save!
            compareEntry.save!
          end
  end
  
  def update_articles
    Feed.all.map { |feed|
      puts "uri: " << feed.uri
      if(feed.title != "Gizmodo")
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
        find_spot_signature(entry)
        entry.save! #TODO: Error checking
        cluster_articles(entry)
        #make_clusters(entry)
      }
      else
        puts "skipped"
      end
    }
    find_and_show_entries
  end
  
  def store_article_text(entry)
      entry.data = nil;
      puts "storing data"
      response = Net::HTTP.get(URI.parse(entry.link))
      if(response.downcase.include?("<h1>moved permanently</h1>"))
        html = Nokogiri::HTML(response, nil, 'UTF-8')
        tag = html.css("a")
        link = tag.attribute('href')
#        puts "new link:"
#        puts link
        response = Net::HTTP.get(URI.parse(link))
#        if(entry.source == "Gizmodo")
#          puts response
#          sleep 5
#        end
      end
      data = Readability::Document.new(response || "")
      if(data.content == nil || data.content.length < 15)
        entry.data = entry.description
      else
        entry.data = data.content.gsub(/<[^>]+>/,"").squeeze(" ").strip || ""
      end
  end
  
  def find_spot_signature(entry)
     tokens = entry.data.downcase.split(' ')
     pos = 0
     spots = []
     currSig = ""
     tokens.each {|token|
                  if APP_CONFIG['antecedents'].include?(token)
                    pos = 1
                  end
                  if pos > 0
                    currSig += "#{token} "
                    pos+=1
                  end
                  if pos == 4
                    spots << currSig.gsub(/[.,";:?!]/,"").squeeze(" ").strip
                    currSig = ""
                    pos = 0
                  end
                  }
     spots = spots.uniq
     entry.spot_signature = spots.join(' || ')
  end
  
  def make_clusters(entry)
    best_similarities = 0
    best_entry = nil
    best_matches = []
    RssEntry.all(:conditions => "spot_signature <> '' AND (rss_entries.source != 'Gizmodo')").each {|compareEntry|
      if((entry.id != compareEntry.id) && (entry.link != compareEntry.link))
        similarities = 0
        matches = []
        spots = compareEntry.spot_signature.split(" || ")
        entry.spot_signature.split(" || ").each { |currSpot|
          if(spots.include?(currSpot))
            similarities+=1
            matches << currSpot
          end
        }
        if((entry.source != compareEntry.source && similarities >= 4) || (entry.source == compareEntry.source && similarities >= 10) || (entry.source != compareEntry.source && Float(similarities)/entry.spot_signature.split(" || ").length >= 0.2 && similarities >=2)|| (entry.source == compareEntry.source && Float(similarities)/entry.spot_signature.split(" || ").length >= 0.5 && similarities >=4) )
          if(compareEntry.cluster && compareEntry.cluster != "")
            entry.cluster = compareEntry.cluster
            if(entry.save)
              puts "added to existing cluster"
            end
            @cluster = Cluster.find(entry.cluster)
            @cluster.add_article(@cluster, matches, entry.id)
            puts @cluster.list_of_articles
          elsif(entry.cluster && entry.cluster != "")
            compareEntry.cluster = entry.cluster
            if(entry.save)
              puts "added to existing cluster"
            end
            @cluster = Cluster.find(entry.cluster)
            @cluster.add_article(@cluster, matches, compareEntry.id)
            puts @cluster.list_of_articles
          else
            @cluster = Cluster.new
            @cluster.list_of_articles = "#{entry.id} || #{compareEntry.id}"
            puts @cluster.list_of_articles
            @cluster.spot_matches = matches.join(' || ')
            if(@cluster.save)
              puts "new cluster"
            end
            entry.cluster = @cluster.id
            compareEntry.cluster = @cluster.id
            entry.save!
            compareEntry.save!
          end
        end
      end
    }
  end
  
  private
  
  def find_and_show_entries
    # if not search
    if(params[:view] != nil)
      conditions = ""
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
    @start_article_num = ((params[:page] || 1).to_i-1)*20 + 1
    @end_article_num = ((params[:page] || 1).to_i)*20
    @num_of_articles = RssEntry.all.length
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
