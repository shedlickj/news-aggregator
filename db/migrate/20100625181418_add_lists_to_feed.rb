class AddListsToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :lists_by_id, :string
  end

  def self.down
    remove_column :feeds, :lists_by_id
  end
end
