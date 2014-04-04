# LivingSocial code challenge: TSV import service
# author: James Dittrich <james.dittrich@gmail.com>
require 'rubygems'
require 'csv'
require 'sinatra'
require 'haml'
require 'active_record'

get '/' do
  haml :index, :format => :html5
end    
    
# process the uploaded file
post "/" do
  # TODO: authenticate 
  File.open('uploads/' + params['infile'][:filename], "w") do |f|

    csv_params = { 
      :col_sep => '\t', 
      :force_quotes => true, 
      :quote_char => '"',
      :headers => true,
      :return_headers => false
    }

    parsed_file = CSV.read(params['infile'][:tempfile], csv_params)
    puts parsed_file
    
    # TODO: class attributes 
    #customer.name
    #item.description
    #item.price
    #lineItem.quantity
    #merchant.address
    #merchant.name

  end
  return "TSV successfully uploaded."
end
