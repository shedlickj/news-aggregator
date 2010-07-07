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
end
