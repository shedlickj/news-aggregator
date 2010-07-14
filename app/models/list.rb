class List < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id
  
  def get_feeds(list_id)
    list = List.find(list_id)
    return list.feeds_by_id.split(',')
  end
  
  def add_feed(list_id, feed_title)
    list = List.find(list_id)
    feed = Feed.find_by_title(feed_title)
    current_feeds = list.feeds_by_id.split(',')
    if(list.feeds_by_id == '')
      list.feeds_by_id = "#{feed.id}"
    else
      list.feeds_by_id += ",#{feed.id}"
    end
    if(list.save)
      return true
    end
    return false
  end
  
  def convert_titles_to_string(feeds)
    feeds_str = ''
    feeds.each { |feed_title|
      feed = Feed.find_by_title(feed_title)
      if(feeds_str == '')
        feeds_str = "#{feed.id}"
      else
        feeds_str += ",#{feed.id}"
      end
    }
    return feeds_str
  end
end
