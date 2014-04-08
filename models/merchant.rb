class Merchant < ActiveRecord::Base
  validates :name, presence: true
  validates :address, presence: true
  has_many :items
  has_many :customers
  has_many :orders
end