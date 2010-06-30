class AddNameToLists < ActiveRecord::Migration
  def self.up
    add_column :lists, :name, :string
  end

  def self.down
    remove_column :lists, :name
  end
end
