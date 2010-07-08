class Cluster < ActiveRecord::Base
  def add_article(cluster, matches, article_id)
    if(!cluster.list_of_articles.split(" || ").include?("#{article_id}"))
      cluster.list_of_articles += " || #{article_id}"
      cluster.spot_matches += ' || ' + matches.join(' || ')
      if(cluster.save)
        puts "cluster updated"
      end
    end
  end
  
  def get_articles(cluster)
    article_ids = cluster.list_of_articles.split(" || ")
    puts cluster.list_of_articles
    output = []
    article_ids.each { |article_id|
      if(article_id != "")
        article = RssEntry.find(article_id)
        output << "#{article.id} #{article.source}: <a href='#{article.link}' target='_blank'>#{article.title}</a>"
      end
    }
    return output.join(' <br /> ')
  end
  
  def get_leader(cluster)
    article_ids = cluster.list_of_articles.split(" || ")
    articles = []
    article_ids.each { |article_id|
      if(article_id != "")
        article = RssEntry.find(article_id)
        articles << article
      end
    }
    articles.sort! { |a,b| b.published <=> a.published }
    articles.sort! { |a,b| Feed.find_by_title(b.source).rank <=> Feed.find_by_title(a.source).rank }
    return articles.first
  end
  
  def get_followers(cluster)
    article_ids = cluster.list_of_articles.split(" || ")
    articles = []
    article_ids.each { |article_id|
      if(article_id != "")
        article = RssEntry.find(article_id)
        articles << article
      end
    }
    articles.sort! { |a,b| b.published <=> a.published }
    articles.sort! { |a,b| Feed.find_by_title(b.source).rank <=> Feed.find_by_title(a.source).rank }
    output = []
    articles.each { |article|
      if(article != "")
        output << "#{article.published} #{article.source}: <a href='#{article.link}' target='_blank'>#{article.title}</a>"
      end
    }
    return output.join(' <br /> ')
  end
end
