class CreateClusters < ActiveRecord::Migration
  def self.up
    create_table :clusters do |t|
      t.text :list_of_articles
      t.text :spot_matches
      t.timestamps
    end
    add_column :rss_entries, :spot_signature, :text
  end

  def self.down
    drop_table :clusters
    remove_column :rss_entries, :spot_signature
  end
end
