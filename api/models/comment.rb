require 'data_mapper'
require 'digest/sha2'
require 'dm-validations'
require 'uuidtools'
require 'sinatra'

class Comment
  # enable :sessions

  include DataMapper::Resource

  property :id,                   Serial
  property :message,              String

  belongs_to :user

end
