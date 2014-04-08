class Order < ActiveRecord::Base
  validates :quantity, presence: true
  validates :customer_id, presence: true
  validates :merchant_id, presence: true
  validates :item_id, presence: true
  belongs_to :customer
  belongs_to :merchant
  # each order only includes one item at a time.
  has_one :item
end