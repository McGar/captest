class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.decimal :price

      t.timestamps
    end
  end
end
