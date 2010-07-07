class AddClusterToRssEntries < ActiveRecord::Migration
  def self.up
    add_column :rss_entries, :cluster, :string
  end

  def self.down
    remove_column :rss_entries, :cluster
  end
end
