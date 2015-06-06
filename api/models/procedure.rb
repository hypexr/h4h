require 'data_mapper'
require 'digest/sha2'
require 'dm-validations'
require 'uuidtools'
require 'sinatra'

class Procedure
  # enable :sessions

  include DataMapper::Resource

  property :id,                   Serial
  property :name,                 String

  has n, :hospital_procedures
  has n, :hospitals, through: :hospital_procedures
end
