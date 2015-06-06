require 'sinatra/base'
require 'data_mapper'
require 'json'

DataMapper.setup(:default, 'mysql://localhost/h4h')

gem 'soda-ruby', :require => 'soda'
require 'soda/client'

require 'rest-client'

require_relative 'authorization'
require_relative 'models/user'
require_relative 'models/comment'
require_relative 'models/hospital'
require_relative 'models/procedure'
require_relative 'models/hospital_procedure'

# DataMapper.finalize
#
# DataMapper.auto_migrate!

class App < Sinatra::Base

  enable :sessions
  set :session_secret, "9f8099cb17e047f3b4a7eaad840103f7977ad0496b124ac7bf234abd5d5b6a128a491d89236745f8ab134cbcb172b984"

  # Sinatra options:
  set :logging,       true
  set :dump_errors,   true
  set :static,        true
  set :public_folder, 'public'

  get '/test' do
    "Application is running"
  end

  get '/test_data' do
    #client = SODA::Client.new({:domain => "chhs.data.ca.gov", :app_token => "CBvxPtbBujDfoeKqYYOatBVXY"})

    #client = SODA::Client.new({:domain => "cdph.data.ca.gov"})
    #soda_response = client.get("ezms-cei8", {"$limit": 5})

    client = SODA::Client.new({:domain => "chhs.data.ca.gov"})
    #soda_response = client.get("x4kp-ag8p", {"$limit": 5, "$county_code": "10 - Fresno"})
    soda_response = client.get("x4kp-ag8p", {"$limit": 5})

    # #client = SODA::Client.new({:domain => "data.cityofchicago.org"})
    # #soda_response = client.get("alternative-fuel-locations")
    # soda_response = client.get("alternative-fuel-locations", {"$limit": 2})
    # #soda_response = client.get("alternative-fuel-locations", {"$limit": 2, "$zip": "60601"})

    return soda_response.to_json
  end

  get '/test_data2' do
    url = "http://api.censusreporter.org/1.0/data/show/latest?table_ids=B17001&geo_ids=16000US0627000"

    response = RestClient.get  url
    return response.to_s
  end

  get '/myself' do
    user = User.get(session[:user_id])
    return user.to_json(methods: [ :comments ])
  end

  get '/create_test_user' do
    user = User.new
    user.email = "example@example.com"
    user.password='12345'
    user.save
  end

  get '/create_test_comment' do
    user = User.get(session[:user_id])
    comment = Comment.new
    comment.message = "New comment"
    comment.user = user
    comment.save
  end



  post '/authenticate' do
    if User.authenticate(@body['email'], @body['password'])
      puts "Authenticated"
      #session[:user_email] = @body['email']
      user = User.first(email: @body['email'])
      session[:user_id] = user[:id]
      status 200
    else
      session.delete :user_id
      throw :halt, [ 401, 'Authorization Required' ]
    end
  end

  get('/authenticate') do
    if session[:user_id]
      status 200
    else
      throw :halt, [ 401, 'Authorization Required' ]
    end
  end

  delete('/authenticate') do
    session.delete :user_id
  end


  get('/hospitals') do
    puts "PARAMS: #{params}"
    rating_criteria = params['rating_criteria']
    county = params['county']
    procedure = params['procedure']

    return Hospital.all({rating_criteria: rating_criteria, county: county, procedure: procedure}).to_json
  end


  before do
    # # Verify authenticated
    # if not request.path.eql? '/authenticate'
    #   throw :halt, [ 401, 'Authorization Required' ] unless session[:user_id]
    # end

    # Load the body as JSON into @body for POST and PUT requests
    if request.request_method.eql? "POST" or request.request_method.eql? "PUT"
      request.body.rewind
      begin
        @body = JSON.parse request.body.read
        #@body = ActiveSupport::JSON.decode(request.body.read)
      rescue Exception => e
        puts "Exception parsing message body #{e}"
        @body = {}
      end
    end
  end

end

