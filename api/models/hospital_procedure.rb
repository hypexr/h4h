require 'data_mapper'
require 'digest/sha2'
require 'dm-validations'
require 'uuidtools'
require 'sinatra'

class HospitalProcedure
  # enable :sessions

  include DataMapper::Resource

  belongs_to :hospital, :key => true
  belongs_to :procedure, :key => true
end
