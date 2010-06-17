class CreateRssEntries < ActiveRecord::Migration
  def self.up
    create_table :rss_entries do |t|
      t.string :source
      t.string :title
      t.datetime :published
      t.string :link
      t.string :description
      t.string :data
      t.boolean :hidden
      t.boolean :favorite

      t.timestamps
    end
  end

  def self.down
    drop_table :rss_entries
  end
end
