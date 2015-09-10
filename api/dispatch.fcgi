#!/usr/bin/ruby
#

ENV["GEM_HOME"] = "/home1/fatpengu/ruby/gems"
require 'rubygems'
require 'fcgi'
require 'sinatra'
require './app'
 
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
  get '/api/hi' do
    "/api/hi---- Hello World!"
  end

  get '/hi' do
    "/hi Hello World!"
  end
end

builder = Rack::Builder.new do
  use Rack::ShowStatus
  use Rack::ShowExceptions

  map '/' do
    run App.new
  end
end

Rack::Handler::FastCGI.run(builder)

