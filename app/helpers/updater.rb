require 'feed_tools'
require 'nokogiri'
require 'clockwork'
include Clockwork

require 'config/boot'
require 'config/environment'

@@diff_source_min_sim = 4
@@diff_source_min_sim_p = 2
@@diff_source_min_per = 0.2
@@same_source_min_sim = 10
@@same_source_min_sim_p = 4
@@same_source_min_per = 0.5
@@perfect_match = 0.9

handler do |job|
  puts "Running #{job}"
#  update_articles
#  puts "Done updating"
#  calculate_article_scores
  calculate_cluster_scores
  puts "Task complete"
end

every(12.hours, 'recurring.job')

def update_articles
  @@current_articles = Article.all.select{|some_article| (Time.now <=> some_article.rss_entry.published)/(60*60*24) <= 3 }
  feeds_done = []
  Feed.all.map { |feed|
    puts "uri: " << feed.uri
    if(!feeds_done.include?(feed.uri))
      open_feed = FeedTools::Feed.open( feed.uri ) #TODO: Error checking
      open_feed.items.map { |item|
        
        # Only save articles with a source and title
        if(item.source && item.title)
          # Find or create new entry
          if(entry = RssEntry.find_by_title(item.title))
            entry_existed = true
          else
            entry = RssEntry.create
            entry_existed = false
          end
          
          # Update entry fields
          #entry = RssEntry.find_or_initialize_by_title(item.title)
          entry.source = feed.title.toutf8
          entry.title.toutf8 = item.title.toutf8
          entry.published = item.published || Time.now
          entry.link = (item.link || "#").toutf8
          entry.description = (item.description || "No description").gsub(/<[^>]+>/,"").squeeze(" ").strip.toutf8
          
          # Scrape article text, find spot_signature if it is new
          text_is_new = store_article_text(entry)
          if(text_is_new)
            puts "finding spot sig"
            find_spot_signature(entry)
            puts "done spot sig"
          end
          entry.save! #TODO: Error checking
          
          # Create new article for entry for each feed that contains it
          if(!entry_existed)
            puts "create articles"
            Feed.all.select{|feed_matching_entry| feed_matching_entry.uri == feed.uri}.each{ |feed_matching_entry|
              article = Article.create
              article.hidden ||= false
              article.favorite ||= false
              article.user_id = feed_matching_entry.user_id
              article.rss_entry_id = entry.id
              article.save! #TODO: Error checking
              @@current_articles << article
            }
            puts "done create articles"
          end
          
          # Cluster each article if the text is new/has changed
          if(text_is_new)
            entry.articles.each{ |article|
              # Remove article from cluster if it is in one
              if(article.cluster)
                cluster = Cluster.find(article.cluster)
                article.cluster = nil
                cluster.remove_article(cluster, article.id) #TODO: remove article from clusters
              end
              if(article.rss_entry.source != "Gizmodo")
                puts "cluster"
                cluster_articles(article)
                puts "cluster done"
              end
            }
          end
        end
      }
      feeds_done << feed.uri
    else
      puts "#{feed.title} already updated"
    end
  }
end


# Gets article from entry link, saves text from article in db
# returns true if data has been changed
def store_article_text(entry)
  puts "storing data"
  if(entry.link != '#')
    
    # Get html from link
    response = Net::HTTP.get(URI.parse(entry.link))
    if(response.downcase.include?("<h1>moved permanently</h1>"))
      html = Nokogiri::HTML(response, nil, 'UTF-8')
      tag = html.css("a")
      link = tag.attribute('href')
      response = Net::HTTP.get(URI.parse(link))
    end
    
    # Use readability to find text from html
    data = Readability::Document.new(response || "")
    if(data.content == nil || data.content.length < 15)
      new_data = entry.description.toutf8
    else
      new_data = data.content.gsub(/<[^>]+>/,"").squeeze(" ").strip.toutf8 || ""
    end
    
  else
    new_data = entry.description
  end
  
  # Save data if new
  if(!entry.data || entry.data != new_data)
    entry.data = new_data
    return true
  end
  return false
end

# Find spot signature of article data
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

# Find cluster for article if a similar article exists
def cluster_articles(article)
  entry = article.rss_entry
  user = User.find(article.user_id)
  
  best_similarities = 0
  best_article = nil
  best_matches = []
  
  # Compare with each article that is <= 3 days old
  #user.articles.select{|some_article| (@@current_time <=> some_article.rss_entry.published)/(60*60*24) <= 3}.each { |compareArticle|
  @@current_articles.select{|some_article| some_article.user_id == user.id}.each { |compareArticle|
    compareEntry = compareArticle.rss_entry
    if((entry.id != compareEntry.id) && (compareEntry.spot_signature != ''))
      similarities = 0
      matches = []
      spots = compareEntry.spot_signature.split(" || ")
      
      # Determine number of similarities with current article
      entry.spot_signature.split(" || ").each { |currSpot|
        if(spots.include?(currSpot))
          similarities+=1
          matches << currSpot
        end
      }
      
      # Determine if pair is a match
      if(((entry.source != compareEntry.source) && (similarities >= @@diff_source_min_sim || (Float(similarities)/entry.spot_signature.split(" || ").length >= @@diff_source_min_per && similarities >= @@diff_source_min_sim_p))) || ((entry.source == compareEntry.source) && (similarities >= @@same_source_min_sim || (Float(similarities)/entry.spot_signature.split(" || ").length >= @@diff_source_min_per && similarities >= @@same_source_min_sim_p))))
        if(similarities > best_similarities)  # closer match found
          # Guarantees that a perfect match or the best match in a cluster is chosen
          puts Float(similarities)/entry.spot_signature.split(" || ").length
          if(Float(similarities)/entry.spot_signature.split(" || ").length >= @@perfect_match || compareArticle.cluster != nil)
            best_similarities = similarities
            best_article = compareArticle
            best_matches = matches
          elsif(best_article && best_article.cluster != nil) # old match was in a cluster
            #do nothing
          else  # neither in a cluster, choose closest match
            best_similarities = similarities
            best_article = compareArticle
            best_matches = matches              
          end
        end
      end
    end
  }
  
  # Cluster if there is a match
  if(best_similarities > 0)
    add_to_cluster(article, best_article, best_matches)
  end
end

# Either add to compare_article's cluster or create a new cluster
def add_to_cluster(article, compare_article, matches)
  if(compare_article.cluster && compare_article.cluster != "") #If other article is clustered, add current article to that cluster
    article.cluster = compare_article.cluster
    if(article.save)
      puts "added to existing cluster"
    end
    new_cluster = Cluster.find(article.cluster)
    new_cluster.add_article(new_cluster, matches, article.id)
    puts new_cluster.list_of_articles
  else                                                   #Otherwise, make a new cluster
    new_cluster = Cluster.new
    new_cluster.list_of_articles = "#{article.id} || #{compare_article.id}"
    puts new_cluster.list_of_articles
    new_cluster.spot_matches = matches.join(' || ')
    if(new_cluster.save)
      puts "new cluster"
    end
    if(new_cluster.get_leader(new_cluster).id == article.id)
      compare_article.cluster_follower = true
    else
      article.cluster_follower = true
    end
    article.cluster = new_cluster.id
    compare_article.cluster = new_cluster.id
    article.save!
    compare_article.save!
  end
end

# Calculate scores of all articles
def calculate_article_scores
  puts "finding article scores"
  Article.all.each { |article|
    score = 0;
    entry = article.rss_entry
    if(entry.published)
      score += (Time.now - entry.published)/360 #increment score by # of hours
    else
      score += (Time.now - entry.created_at)/360 #increment score by # of hours
    end
    if(article.cluster)
      score += 5 #cluster penalty
      cluster = Cluster.find(article.cluster)
      score += cluster.size(cluster)*2 #penalty for larger clusters
    end
    article.score = score
    article.save!
  }
end

# Calculate scores of all clusters
def calculate_cluster_scores
  puts "finding cluster scores"
  Cluster.all.each { |cluster|
    score = 0;
    leader = cluster.get_leader(cluster).rss_entry
    if(leader.published)
      score += (Time.now - leader.published)/360 #increment score by # of hours
    else
      score += (Time.now - leader.created_at)/360 #increment score by # of hours
    end
    score -= cluster.size(cluster)*3 #larger clusters are better
    cluster.score = score
    cluster.save!
  }
end