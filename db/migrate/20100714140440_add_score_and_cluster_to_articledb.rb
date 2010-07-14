class AddScoreAndClusterToArticledb < ActiveRecord::Migration
  def self.up
    add_column :articles, :score, :decimal
    add_column :articles, :cluster, :string
  end

  def self.down
    remove_column :articles, :score
    remove_column :articles, :cluster
  end
end
