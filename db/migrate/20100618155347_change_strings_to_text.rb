class ChangeStringsToText < ActiveRecord::Migration
  def self.up
    change_column :rss_entries, :description, :text
  end

  def self.down
    change_column :rss_entries, :description, :string
  end
end
