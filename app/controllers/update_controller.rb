require 'feed_tools'

class UpdateController < ApplicationController
  # GET /rss_entries
  # GET /rss_entries.xml
  def index
    @feeds = Feed.all
    open_feeds

    @rss_entries = RssEntry.all

    respond_to do |format|
      format.html { redirect_to(rss_entries_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def open_feeds
    Feed.all.map { |feed|
      puts "uri: " << feed.uri
      open_feed = FeedTools::Feed.open( feed.uri )
      open_feed.items.map { |item|
        entry = RssEntry.find_or_initialize_by_title(item.title)
        entry.source = feed.title
        entry.title = item.title
        entry.published = item.published
        entry.link = item.link
        entry.description = item.description.gsub(/<[^>]+>/,"").squeeze(" ").strip
        entry.data = item.media_text
        entry.hidden ||= false
        entry.favorite ||= false
        entry.save! #TODO: Error checking
      }
    }
  end
end
