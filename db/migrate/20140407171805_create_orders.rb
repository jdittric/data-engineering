class CreateOrders < ActiveRecord::Migration
  def self.up

    create_table :customers do |t|
      t.string :name
      t.timestamps
    end

    create_table :items do |t|
      t.string :description
      t.float :price
      t.timestamps
    end

    create_table :merchants do |t|
      t.string :name
      t.string :address
      t.timestamps
    end

    create_table :orders do |t|
      t.integer :quantity
      t.integer :item_id
      t.integer :customer_id
      t.integer :merchant_id
      t.timestamps
    end
  end
 
  def self.down
    drop_table :customers
    drop_table :items
    drop_table :merchants
    drop_table :orders
  end
end
