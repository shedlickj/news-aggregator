class UpdateTablesForUserIntegration < ActiveRecord::Migration
  def self.up
    create_table(:articles) do |t|
      t.integer :user_id
      t.integer :rss_entry_id
      t.boolean :hidden
      t.boolean :favorite
      t.timestamps
    end
    add_column :feeds, :user_id, :integer
    add_column :lists, :user_id, :integer
    add_column :clusters, :user_id, :integer
  end

  def self.down
    drop_table :articles
    remove_column :feeds, :user_id
    remove_column :lists, :user_id
    remove_column :clusters, :user_id
  end
end
