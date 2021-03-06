# LivingSocial code challenge: TSV import service
# author: James Dittrich <james.dittrich@gmail.com>
require 'rubygems'
require 'csv'
require 'sinatra'
require 'haml'
require 'sqlite3'
require 'active_record'
require 'rack/openid'
require 'warden'
require_relative 'models/customer'
require_relative 'models/merchant'
require_relative 'models/item'
require_relative 'models/order'

use Rack::Session::Cookie, :key => 'rack.session',
                           :domain => 'localhost',
                           :path => '/',
                           :expire_after => 6000, # In seconds
                           :secret => 'change_me' # should be set by env in production

helpers do
  def warden
    env['warden']
  end
end

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database =>  'tsv_service.sqlite3.db'
)

#=begin WARDEN OPENID AUTH
use Rack::OpenID
use Warden::Manager do |manager|
  Warden::Strategies.add(:openid) do
    def authenticate!
      if resp = env["rack.openid.response"]
        case resp.status
        when :success
          u = env["rack.openid.response"].identity_url
          success!(u)
        when :cancel
          fail!("OpenID auth cancelled")
        when :failure
          fail!("OpenID auth failed")
        end
      else
        custom!([401, {"WWW-Authenticate" => 'OpenID identifier="https://www.google.com/accounts/o8/id"'}, "OpenID plz"])
      end
    end
  end
  manager.default_strategies :openid
  manager.failure_app = lambda do
    status, headers, body = @application.call(request.env)
    Rack::Response.new(body, status, headers).finish
  end
end

=begin BASIC AUTH
use Rack::Auth::Basic, "Restricted Area" do |user, password|
  user == 'admin' && password == 'secret'
end
=end

get '/' do
  haml :index, :format => :html5
end

post '/login' do
  warden.authenticate!(:openid, :scope => :default)
  redirect to('/')
end

get '/logout' do
  warden.logout(:default)
  redirect to('/')
end

# process the uploaded file
post "/" do
  if !params['infile'][:filename].nil? && warden.authenticated?
    File.open('uploads/' + params['infile'][:filename], "w") do |f|

      csv_params = { 
        :col_sep => "\t",
        :headers => true,
        :header_converters => :symbol,
        :return_headers => false,
        :converters => [:all, :empty_to_nil]
      }

      CSV::Converters[:empty_to_nil] = lambda do |field|
        field && field.empty? ? nil : field
      end
      csv = CSV.read(params['infile'][:tempfile], csv_params)
      puts csv

      session[:import_start_id] = 0
      session[:import_end_id] = 0

      input_obj = csv.map {|row| row.to_hash }
      input_obj.each_with_index do |row, index|
        c = Customer.find_or_create_by( name: row[:purchaser_name] )
        i = Item.find_or_create_by( description: row[:item_description], price: row[:item_price] )
        m = Merchant.find_or_create_by( name: row[:merchant_name], address: row[:merchant_address] )
        o = Order.create( quantity: row[:purchase_count], 
                          item_id: i.id,
                          customer_id: c.id,
                          merchant_id: m.id )
        c.save!
        i.save!
        m.save!
        o.save!
        if index == 0
          session[:import_start_id] = o.id
          puts "Imported order start ID is: #{session[:import_start_id]}"
        elsif index == input_obj.length-1
          session[:import_end_id] = o.id
          puts "Imported order end ID is: #{session[:import_end_id]}"
        end
      end
      session.each { |k,v| puts "#{k}: #{v}" }
      redirect to('/summary')
    end
    
  end
end

get '/summary' do
  haml :summary, :format => :html5
end
