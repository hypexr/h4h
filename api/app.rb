require 'sinatra/base'
require 'data_mapper'
require 'json'
require 'yaml'

db_config = YAML.load_file('db_config.yaml')

#DataMapper.setup(:default, 'mysql://localhost/h4h')
DataMapper.setup(:default, "mysql://#{db_config['user']}:#{db_config['password']}@#{db_config['host']}/#{db_config['db_name']}")

gem 'soda-ruby', :require => 'soda'
require 'soda/client'

require 'rest-client'

require_relative 'models/hospital'
require_relative 'models/procedure'
require_relative 'models/hospital_procedure'

# DataMapper.finalize
#
# DataMapper.auto_migrate!

class App < Sinatra::Base

  # Sinatra options:
  set :logging,       true
  set :dump_errors,   true
  set :static,        true
  set :public_folder, 'public'

  get '/api/test' do
    "Application is running"
  end

  get %r{/(api/)?test_data} do
    #client = SODA::Client.new({:domain => "cdph.data.ca.gov"})
    #soda_response = client.get("ezms-cei8", {"$limit": 5})

    client = SODA::Client.new({:domain => "chhs.data.ca.gov"})
    #soda_response = client.get("x4kp-ag8p", {"$limit": 5, "$county_code": "10 - Fresno"})
    soda_response = client.get("x4kp-ag8p", {"$limit" => 5})

    # #client = SODA::Client.new({:domain => "data.cityofchicago.org"})
    # #soda_response = client.get("alternative-fuel-locations")
    # soda_response = client.get("alternative-fuel-locations", {"$limit": 2})
    # #soda_response = client.get("alternative-fuel-locations", {"$limit": 2, "$zip": "60601"})

    return soda_response.to_json
  end

  get %r{/(api/)?test_data2} do
    url = "http://api.censusreporter.org/1.0/data/show/latest?table_ids=B17001&geo_ids=16000US0627000"

    response = RestClient.get  url
    return response.to_s
  end

  get %r{/(api/)?hospitals} do
    puts "PARAMS: #{params}"
    rating_criteria = params['rating_criteria']
    #county = params['county']
    #procedure = params['procedure']
    county = nil
    procedure = nil

    return Hospital.all({rating_criteria: rating_criteria, county: county, procedure: procedure, order: [ :display_percentage.asc ]}).to_json
  end

end

