class Item < ActiveRecord::Base
  validates :description, presence: true
  validates :price, presence: true, numericality: true
  has_many :orders
  belongs_to :merchant
end