class RssEntry < ActiveRecord::Base
  belongs_to :feed, :class_name=>"Feed", :foreign_key => 'feed_id'
  has_many :articles
  
  def search(search_term, search_results_page)
  search_term = '%' + String(search_term).downcase + '%'
  paginate :order => 'search_field',
    :conditions => [ 'LOWER(title) LIKE ?', search_term],
    :per_page => 10,
    :page => search_results_page
  end

end