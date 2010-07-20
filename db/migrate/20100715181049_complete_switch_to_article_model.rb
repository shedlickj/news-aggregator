class CompleteSwitchToArticleModel < ActiveRecord::Migration
  def self.up
    remove_column :rss_entries, :hidden
    remove_column :rss_entries, :favorite
    remove_column :rss_entries, :score
    remove_column :rss_entries, :cluster
    change_column :articles, :hidden, :boolean, :default => false
    change_column :articles, :favorite, :boolean, :default => false
    change_column :articles, :score, :decimal, :default => 0
    add_column :articles, :cluster_follower, :boolean, :default => false
    add_column :lists, :shared, :boolean, :default => false
    add_column :feeds, :user_update_rank, :integer, :default => 0
  end

  def self.down
    add_column :rss_entries, :hidden, :boolean
    add_column :rss_entries, :favorite, :boolean
    add_column :rss_entries, :score, :decimal
    add_column :rss_entries, :cluster, :string
    change_column :articles, :hidden, :boolean
    change_column :articles, :favorite, :boolean
    change_column :articles, :score, :decimal
    remove_column :articles, :cluster_follower
    remove_column :lists, :shared
    remove_column :feeds, :user_update_rank
  end
end
