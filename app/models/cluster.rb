class Cluster < ActiveRecord::Base
  
  belongs_to :user
  
  def add_article(cluster, matches, article_id)
    if(!cluster.list_of_articles.split(" || ").include?("#{article_id}"))
      prev_leader = get_leader(cluster)
      cluster.list_of_articles += " || #{article_id}"
      cluster.spot_matches += ' || ' + matches.join(' || ')
      if(cluster.save)
        puts "cluster updated"
      end
      if((new_leader = get_leader(cluster)).id != prev_leader.id)
        prev_leader.cluster_follower = true
        prev_leader.save!
        new_leader.cluster_follower = false
        new_leader.save!
      end
    end
  end
  
  def remove_article(cluster, article_id)
    list = cluster.list_of_articles.split(" || ")
    
    # Reset leader if leader is deleted
    if(get_leader(cluster).id == article_id)
      new_leader = true
    end
  
    if(list.delete(article_id))
      cluster.list_of_articles = list.join(' || ')
      if(cluster.save)
        puts "cluster updated"
      end
    end
    
    if(new_leader)
      new_leader = get_leader(cluster)
      new_leader.cluster_follower = false
      new_leader.save!
    end
  end
  
  def get_articles(cluster)
    article_ids = cluster.list_of_articles.split(" || ")
    puts cluster.list_of_articles
    output = []
    article_ids.each { |article_id|
      if(article_id != "")
        article = Article.find(article_id)
        entry = article.rss_entry
        output << "#{entry.id} #{entry.source}: <a href='#{entry.link}' target='_blank'>#{entry.title}</a>"
      end
    }
    return output.join(' <br /> ')
  end
  
  def get_leader(cluster)
    article_ids = cluster.list_of_articles.split(" || ")
    articles = []
    article_ids.each { |article_id|
      if(article_id != "")
        article = Article.find(article_id)
        articles << article
      end
    }
    articles.sort! { |a,b| b.rss_entry.published <=> a.rss_entry.published }
    articles.sort! { |a,b| Feed.find_by_title(b.rss_entry.source).rank <=> Feed.find_by_title(a.rss_entry.source).rank }
    return articles.first
  end
  
  def get_followers(cluster, is_formatted)
    article_ids = cluster.list_of_articles.split(" || ")
    articles = []
    article_ids.each { |article_id|
      if(article_id != "")
        article = Article.find(article_id)
        articles << article
      end
    }
    articles.sort! { |a,b| b.rss_entry.published <=> a.rss_entry.published }
    articles.sort! { |a,b| Feed.find_by_title(b.rss_entry.source).rank <=> Feed.find_by_title(a.rss_entry.source).rank }
    output = []
    articles.each { |article|
      if(article != "" && (article.id != articles.first.id))
        if(is_formatted)
          entry = article.rss_entry
          output << "#{entry.published} #{entry.source}: <a href='#{entry.link}' target='_blank'>#{entry.title}</a>"
        else
          output << article
        end
      end
    }
    if(is_formatted)
      return output.join(' <br /> ')
    end
    return output
  end
  
  def size(cluster)
    return cluster.list_of_articles.split(" || ").length
  end
  
  def get_matches(cluster)
    return cluster.spot_matches.split(" || ").uniq
  end
end
