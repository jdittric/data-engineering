# LivingSocial code challenge: TSV import service
# author: James Dittrich <james.dittrich@gmail.com>
require 'rubygems'
require 'csv'
require 'sinatra'
require 'haml'
require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'tsv_service.sqlite3.db'
)

# stub Model classes
class Customer < ActiveRecord::Base
  validates :name, presence: true
  has_many :orders
  belongs_to :merchant
end 

class Merchant < ActiveRecord::Base
  validates :name, presence: true
  validates :address, presence: true
  has_many :items
  has_many :customers
  has_many :orders
end

class Item < ActiveRecord::Base
  validates :description, presence: true
  validates :price, presence: true
  has_many :orders
  belongs_to :merchant
end

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

# basic auth
# TODO Warden 
use Rack::Auth::Basic, "Restricted Area" do |user, password|
  user == 'admin' && password == 'secret'
end

get '/' do
  haml :index, :format => :html5
end    
    
# process the uploaded file
post "/" do
  # TODO: authenticate
  if params['infile'][:filename] # && authenticated
    File.open('uploads/' + params['infile'][:filename], "w") do |f|

      csv_params = { 
        :col_sep => "\t",
        :headers => true,
        :header_converters => :symbol,
        :return_headers => false,
        :converters => [:all, :empty_to_nil]
      }
      #:quote_char => "\"", 

      # parsed_file = CSV.read(params['infile'][:tempfile], csv_params)
      # puts parsed_file

      CSV::Converters[:empty_to_nil] = lambda do |field|
        field && field.empty? ? nil : field
      end
      csv = CSV.read(params['infile'][:tempfile], csv_params)
      puts csv

      input_obj = csv.map {|row| row.to_hash }
      input_obj.each do |row|
        c = Customer.find_or_create_by( name: row[:purchaser_name] )
        puts c
        i = Item.find_or_create_by( description: row[:item_description], price: row[:item_price] )
        puts i
        m = Merchant.find_or_create_by( name: row[:merchant_name], address: row[:merchant_address] )
        puts m
        o = Order.create( quantity: row[:purchase_count], 
                          item_id: i.id,
                          customer_id: c.id,
                          merchant_id: m.id )
        puts o
        c.save!
        i.save!
        m.save!
        o.save!
      end

      redirect to('/summary')
    end
    
  else
    redirect to('/')
  end
end

get '/summary' do
  @orders = Order.all
  haml :summary, :format => :html5
end
