require 'data_mapper'
DataMapper.setup(:default, 'mysql://localhost/h4h')

require_relative '../models/hospital'
require_relative '../models/procedure'
require_relative '../models/hospital_procedure'

gem 'soda-ruby', :require => 'soda'
require 'soda/client'

# client = SODA::Client.new({:domain => "chhs.data.ca.gov"})
# soda_response = client.get("x4kp-ag8p", {"$limit": 5})
#
# puts soda_response.to_s


counties = [
    "Fresno",
    "Fresno-Kings",
    "Madera",
    "Mariposa",
    "Merced",
    "Monterey",
    "San Benito",
    "Stanislaus",
    "Tulare",
    "Tuolumne"
]

counties.each do |county|
  puts
  puts "#{county} County -----------------------------"
  puts

  client = SODA::Client.new({:domain => "cdph.data.ca.gov"})
  soda_response = client.get("d4t7-iig6", {"county": county})

  puts soda_response.to_s

  soda_response.each do |record|
    hospital_name = record['facility_name1']
    procedure_name = record['operative_procedure']
    puts "County #{record['county']}"
    puts "Facility #{hospital_name}"
    puts "Infection Count #{record['infection_count']}"
    puts "Procedure Count #{record['procedure_count']}"
    puts "Procedure #{procedure_name}"
    puts

    hospital = Hospital.all(name: hospital_name).first
    if hospital.nil?
      hospital = Hospital.new
      hospital.name = hospital_name
      hospital.save
    end

    procedure = Procedure.all(name: procedure_name).first
    if procedure.nil?
      procedure = Procedure.new
      procedure.name = procedure_name
      procedure.save
    end

    hospital.procedures << procedure
    hospital.save

  end
end

puts "Facilities:"
Hospital.all().each do |hospital|
    puts hospital.to_json(methods: [:procedures])
end


