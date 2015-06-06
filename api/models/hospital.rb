require 'data_mapper'
require 'digest/sha2'
require 'dm-validations'
require 'uuidtools'
require 'sinatra'

class Hospital
  # enable :sessions

  include DataMapper::Resource

  property :id,                   Serial
  property :name,                 String

  has n, :hospital_procedures
  has n, :procedures, through: :hospital_procedures
end
