class AddScoreToClusters < ActiveRecord::Migration
  def self.up
    add_column :clusters, :score, :integer, :default => 0
  end

  def self.down
    remove_column :clusters, :score
  end
end
