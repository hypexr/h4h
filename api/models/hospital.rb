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
  property :rating_criteria,      String
  property :procedure,            String
  property :procedures,           String
  property :county,               String
  property :occurrences,          Integer
  property :out_of,               Integer
  property :risk_ratio,           Integer
  property :min_occurrences,      Integer
  property :max_occurrences,      Integer
  property :display_ratio,        Integer

  # has n, :hospital_procedures
  # has n, :procedures, through: :hospital_procedures

  def initialize hospital=nil
    if not hospital.nil?
      self.name = hospital.name
      self.rating_criteria = hospital.rating_criteria
      self.procedure = hospital.procedure
      self.procedures = hospital.procedures
      self.county = hospital.county
      self.occurrences = hospital.occurrences
      self.out_of = hospital.out_of
    end
  end
end
