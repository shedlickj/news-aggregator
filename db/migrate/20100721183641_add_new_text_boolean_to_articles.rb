class AddNewTextBooleanToArticles < ActiveRecord::Migration
  def self.up
     add_column :articles, :has_new_text, :boolean, :default => false
  end

  def self.down
     remove_column :articles, :has_new_text
  end
end
