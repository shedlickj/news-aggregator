class AddScoreToEntries < ActiveRecord::Migration
  def self.up
    add_column :rss_entries, :score, :decimal
  end

  def self.down
    remove_column :rss_entries, :score
  end
end
