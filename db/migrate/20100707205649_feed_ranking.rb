class FeedRanking < ActiveRecord::Migration
  def self.up
    add_column :feeds, :rank, :string
  end

  def self.down
    remove_column :feeds, :rank
  end
end
