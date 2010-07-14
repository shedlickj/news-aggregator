require 'feed_tools'

class Feed < ActiveRecord::Base
  
  belongs_to :user
  has_many :rss_entries
  
  validates_presence_of :title, :uri
  validates_uniqueness_of :title, :uri, :scope => :user_id
  validate do |feed|
    valid = true
    begin
      FeedTools::Feed.open( feed.uri )
    rescue FeedTools::FeedAccessError
      valid = false
    end
    feed.errors.add_to_base("Could not connect to URL - Invalid") if valid == false
  end
  
  def rss_entries
    RssEntry.all :conditions => ['feed_id = ?', self.id]
  end
end