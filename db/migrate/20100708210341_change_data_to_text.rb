class ChangeDataToText < ActiveRecord::Migration
  def self.up
    change_column :rss_entries, :data, :text
  end

  def self.down
    change_column :rss_entries, :data, :string
  end
end
