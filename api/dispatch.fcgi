#!/usr/bin/ruby
#

ENV["GEM_HOME"] = "/home1/fatpengu/ruby/gems"
require 'rubygems'
require 'fcgi'
require 'sinatra'

module Rack
  class Request
    def path_info
      @env["REDIRECT_URL"].to_s
    end
    def path_info=(s)
      @env["REDIRECT_URL"] = s.to_s
    end
  end
end

# Define your Sinatra application here
class MyApp < Sinatra::Application
  get '/hi' do
    "Hello World!"
  end
end

builder = Rack::Builder.new do
  use Rack::ShowStatus
  use Rack::ShowExceptions

  map '/' do
    run MyApp.new
  end
end

Rack::Handler::FastCGI.run(builder)
