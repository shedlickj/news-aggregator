class ChangeTitleToText < ActiveRecord::Migration
  def self.up
    change_column :rss_entries, :title, :text
  end

  def self.down
    change_column :rss_entries, :title, :string
  end
end
