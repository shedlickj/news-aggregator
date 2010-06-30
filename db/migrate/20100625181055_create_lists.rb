class CreateLists < ActiveRecord::Migration
  def self.up
    create_table :lists do |t|
      t.string :feeds_by_id
      t.boolean :default_list,         :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :lists
  end
end
