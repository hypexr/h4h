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

class Integer
  N_BYTES = [42].pack('i').size
  N_BITS = N_BYTES * 16
  MAX = 2 ** (N_BITS - 2) - 1
  MIN = -MAX - 1
end

# Clear old hospital data
hospitals = Hospital.all()
hospitals.each do |hospital|
  hospital.destroy
end

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


def set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
  # top_limit = max_occurrences - min_occurrences
  # stdandardized_occurrences = hospital.occurrences - min_occurrences
  # if(top_limit == 0)
  #   hospital.display_percentage = 0
  # else
  #   hospital.display_percentage = (stdandardized_occurrences / top_limit) * 100
  # end

  if(hospital.display_percentage == nil)
    if(hospital.out_of == 0)
      hospital.display_percentage = 0
    else
      puts "Criteria: #{hospital.rating_criteria}. Procedure: #{hospital.procedure}. County: #{hospital.county}. Occurrences: #{hospital.occurrences}. Out of: #{hospital.out_of}"
      hospital.display_percentage = (hospital.occurrences.to_f / hospital.out_of.to_f) * 100
    end
  end
  hospital.save
  puts "............. #{hospital.name} rank: #{hospital.display_percentage}"
end



#
#
# Ingest Surgical Site Infections SSI data
#
#
min_occurrences = Integer::MAX
max_occurrences = 0
procedures = []
counties.each do |county|
  puts
  puts "#{county} County -----------------------------"
  puts

  # Surgical Site Infections SSIs
  client = SODA::Client.new({:domain => "cdph.data.ca.gov"})
  soda_response = client.get("d4t7-iig6", {"county": county})

  # puts soda_response.to_s

  soda_response.each do |record|
    procedure_name = record['operative_procedure'].strip
    procedure = Procedure.all(name: procedure_name).first
    if procedure.nil?
      procedure = Procedure.new
      procedure.name = procedure_name
      procedure.save
    end

    if not procedures.include? procedure.name
      procedures << procedure.name
    end
  end

  soda_response.each do |record|
    procedure_name = record['operative_procedure']
    facility_name = record['facility_name1']
    puts "County #{record['county']}"
    puts "Facility #{facility_name}"
    puts "Infection Count #{record['infection_count']}"
    puts "Procedure Count #{record['procedure_count']}"
    puts "Procedure #{procedure_name}"
    puts

    hospital = Hospital.new
    hospital.name = facility_name
    hospital.procedure = procedure_name
    hospital.county = county
    hospital.rating_criteria = 'SSIs'
    hospital.occurrences = record['infection_count']
    hospital.occurrences = 0 if hospital.occurrences.nil?
    hospital.out_of = record['procedure_count']
    hospital.out_of = 0 if hospital.out_of.nil?
    hospital.save

    if hospital.occurrences != nil and hospital.occurrences < min_occurrences
      min_occurrences = hospital.occurrences
    end
    if hospital.occurrences != nil and  hospital.occurrences > max_occurrences
      max_occurrences = hospital.occurrences
    end

    # Add to the global list of procedures that'll be used in procedure dropdowns
    procedure = Procedure.all(name: procedure_name).first
    if procedure.nil?
      procedure = Procedure.new
      procedure.name = procedure_name
      procedure.save
    end
  end
end

# Set min and max occurrences for each record that was inserted
min_occurrences = 0 if min_occurrences != Integer::MAX
hospitals = Hospital.all()
hospitals.each do |hospital|
  hospital.min_occurrences = min_occurrences
  hospital.max_occurrences = max_occurrences
  set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
end



# Generate rating_type, procedure, county = nil
procedures.each do |procedure|
  min_occurrences = Integer::MAX
  max_occurrences = 0
  hospital_names = []
  hospital_ids = {}

  puts "Creating hospitals for rating_criteria: SSIs procedure #{procedure}"
  hospitals = Hospital.all({'rating_criteria': 'SSIs', 'procedure': procedure})
  hospitals.each do |hospital|
    if not hospital_names.include? hospital.name
      hospital = Hospital.new hospital
      hospital.county = nil
      hospital.save
      hospital_names << hospital.name
      hospital_ids[hospital.name] = hospital.id
    else
      existing_hospital = Hospital.get(hospital_ids[hospital.name])
      existing_hospital.occurrences += hospital.occurrences
      existing_hospital.save
      hospital = existing_hospital
    end

    if hospital.occurrences != nil and hospital.occurrences < min_occurrences
      min_occurrences = hospital.occurrences
    end
    if hospital.occurrences != nil and  hospital.occurrences > max_occurrences
      max_occurrences = hospital.occurrences
    end
  end

  # Set min and max occurrences for each record that was inserted
  min_occurrences = 0 if min_occurrences != Integer::MAX
  hospitals = Hospital.all({'rating_criteria': 'SSIs', 'procedure': procedure, 'county': nil})
  hospitals.each do |hospital|
    hospital.min_occurrences = min_occurrences
    hospital.max_occurrences = max_occurrences
    set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
  end
end



# Generate rating_type, county, procedure = nil
counties.each do |county|
  min_occurrences = Integer::MAX
  max_occurrences = 0
  hospital_names = []
  hospital_ids = {}

  puts "Creating hospitals for rating_criteria: SSIs county #{county}"
  hospitals = Hospital.all({'rating_criteria': 'SSIs', 'county': county})
  hospitals.each do |hospital|
    if not hospital_names.include? hospital.name
      hospital = Hospital.new hospital
      hospital.procedure = nil
      hospital.save
      hospital_names << hospital.name
      hospital_ids[hospital.name] = hospital.id
    else
      existing_hospital = Hospital.get(hospital_ids[hospital.name])
      existing_hospital.occurrences += hospital.occurrences
      existing_hospital.save
      hospital = existing_hospital
    end

    if hospital.occurrences != nil and hospital.occurrences < min_occurrences
      min_occurrences = hospital.occurrences
    end
    if hospital.occurrences != nil and hospital.occurrences > max_occurrences
      max_occurrences = hospital.occurrences
    end
  end

  # Set min and max occurrences for each record that was inserted
  min_occurrences = 0 if min_occurrences != Integer::MAX
  hospitals = Hospital.all({'rating_criteria': 'SSIs', 'county': county, 'procedure': nil})
  hospitals.each do |hospital|
    hospital.min_occurrences = min_occurrences
    hospital.max_occurrences = max_occurrences
    set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
  end
end




# Generate rating_type, procedure = nil, county = nil
min_occurrences = Integer::MAX
max_occurrences = 0
hospital_names = []
hospital_ids = {}

puts "Creating hospitals for rating_criteria: SSIs, No county, No procedure"
hospitals = Hospital.all({'rating_criteria': 'SSIs'})
hospitals.each do |hospital|
  if not hospital_names.include? hospital.name
    hospital = Hospital.new hospital
    hospital.procedure = nil
    hospital.county = nil
    hospital.save
    hospital_names << hospital.name
    hospital_ids[hospital.name] = hospital.id
  else
    existing_hospital = Hospital.get(hospital_ids[hospital.name])
    existing_hospital.occurrences += hospital.occurrences
    existing_hospital.save
    hospital = existing_hospital
  end

  if hospital.occurrences != nil and hospital.occurrences < min_occurrences
    min_occurrences = hospital.occurrences
  end
  if hospital.occurrences != nil and hospital.occurrences > max_occurrences
    max_occurrences = hospital.occurrences
  end
end

# Set min and max occurrences for each record that was inserted
min_occurrences = 0 if min_occurrences != Integer::MAX
hospitals = Hospital.all({'rating_criteria': 'SSIs', 'procedure': nil, 'county': nil})
hospitals.each do |hospital|
  hospital.min_occurrences = min_occurrences
  hospital.max_occurrences = max_occurrences
  set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
end









#
#
# Ingest Infection mortality data
#
#
min_occurrences = Integer::MAX
max_occurrences = 0
procedures = []
counties.each do |county|
  puts
  puts "#{county} Mortality -----------------------------"
  puts

  client = SODA::Client.new({:domain => "chhs.data.ca.gov"})
  soda_response = client.get("652m-fw2m", {"county": county})

  puts soda_response.to_s

  soda_response.each do |record|

    # Add procedure if it doesn't already exist to the complete list of procedures
    procedure_name = record['procedure_condition'].strip
    procedure = Procedure.all(name: procedure_name).first
    if procedure.nil?
      procedure = Procedure.new
      procedure.name = procedure_name
      procedure.save
    end

    if not procedures.include? procedure.name
      procedures << procedure.name
    end
  end

  soda_response.each do |record|
    procedure_name = record['procedure_condition']
    facility_name = record['hospital']
    puts "County #{record['county']}"
    puts "Facility #{facility_name}"
    puts "Occurrences #{record['of_deaths']}"
    puts "Out of #{record['of_cases']}"
    puts "Procedure #{procedure_name}"
    puts

    hospital = Hospital.new
    hospital.name = facility_name
    hospital.procedure = procedure_name
    hospital.county = county
    hospital.rating_criteria = 'mortality'
    hospital.occurrences = record['of_deaths']
    hospital.occurrences = 0 if hospital.occurrences.nil?
    hospital.out_of = record['of_cases']
    hospital.out_of = 0 if hospital.out_of.nil?
    rate = record['risk_adjuested_mortality_rate']
    #if(rate.is_a? Numeric)
      puts "===================rate #{rate}"
      puts "===================rate #{rate}"
      hospital.display_percentage = rate.to_f
    # else
    #   hospital.display_percentage = 0
    #   hospital.occurrence_data_available = false
    # end
    hospital.save

    if hospital.occurrences != nil and hospital.occurrences < min_occurrences
      min_occurrences = hospital.occurrences
    end
    if hospital.occurrences != nil and  hospital.occurrences > max_occurrences
      max_occurrences = hospital.occurrences
    end

    # Add to the global list of procedures that'll be used in procedure dropdowns
    procedure = Procedure.all(name: procedure_name).first
    if procedure.nil?
      procedure = Procedure.new
      procedure.name = procedure_name
      procedure.save
    end
  end
end

# Set min and max occurrences for each record that was inserted
min_occurrences = 0 if min_occurrences != Integer::MAX
hospitals = Hospital.all()
hospitals.each do |hospital|
  hospital.min_occurrences = min_occurrences
  hospital.max_occurrences = max_occurrences
  set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
end



# Generate rating_type, procedure, county = nil
procedures.each do |procedure|
  min_occurrences = Integer::MAX
  max_occurrences = 0
  hospital_names = []
  hospital_ids = {}

  puts "Creating hospitals for rating_criteria: mortality procedure #{procedure}"
  hospitals = Hospital.all({'rating_criteria': 'mortality', 'procedure': procedure})
  hospitals.each do |hospital|
    if not hospital_names.include? hospital.name
      hospital = Hospital.new hospital
      hospital.county = nil
      hospital.save
      hospital_names << hospital.name
      hospital_ids[hospital.name] = hospital.id
    else
      existing_hospital = Hospital.get(hospital_ids[hospital.name])
      existing_hospital.occurrences += hospital.occurrences
      existing_hospital.save
      hospital = existing_hospital
    end

    if hospital.occurrences != nil and hospital.occurrences < min_occurrences
      min_occurrences = hospital.occurrences
    end
    if hospital.occurrences != nil and  hospital.occurrences > max_occurrences
      max_occurrences = hospital.occurrences
    end
  end

  # Set min and max occurrences for each record that was inserted
  min_occurrences = 0 if min_occurrences != Integer::MAX
  hospitals = Hospital.all({'rating_criteria': 'mortality', 'procedure': procedure, 'county': nil})
  hospitals.each do |hospital|
    hospital.min_occurrences = min_occurrences
    hospital.max_occurrences = max_occurrences
    set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
  end
end



# Generate rating_type, county, procedure = nil
counties.each do |county|
  min_occurrences = Integer::MAX
  max_occurrences = 0
  hospital_names = []
  hospital_ids = {}

  puts "Creating hospitals for rating_criteria: mortality county #{county}"
  hospitals = Hospital.all({'rating_criteria': 'mortality', 'county': county})
  hospitals.each do |hospital|
    if not hospital_names.include? hospital.name
      hospital = Hospital.new hospital
      hospital.procedure = nil
      hospital.save
      hospital_names << hospital.name
      hospital_ids[hospital.name] = hospital.id
    else
      existing_hospital = Hospital.get(hospital_ids[hospital.name])
      existing_hospital.occurrences += hospital.occurrences
      existing_hospital.save
      hospital = existing_hospital
    end

    if hospital.occurrences != nil and hospital.occurrences < min_occurrences
      min_occurrences = hospital.occurrences
    end
    if hospital.occurrences != nil and hospital.occurrences > max_occurrences
      max_occurrences = hospital.occurrences
    end
  end

  # Set min and max occurrences for each record that was inserted
  min_occurrences = 0 if min_occurrences != Integer::MAX
  hospitals = Hospital.all({'rating_criteria': 'mortality', 'county': county, 'procedure': nil})
  hospitals.each do |hospital|
    hospital.min_occurrences = min_occurrences
    hospital.max_occurrences = max_occurrences
    set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
  end
end



# Generate rating_type, procedure = nil, county = nil
min_occurrences = Integer::MAX
max_occurrences = 0
hospital_names = []
hospital_ids = {}

puts "Creating hospitals for rating_criteria: mortality, No county, No procedure"
hospitals = Hospital.all({'rating_criteria': 'mortality'})
hospitals.each do |hospital|
  if not hospital_names.include? hospital.name
    hospital = Hospital.new hospital
    hospital.procedure = nil
    hospital.county = nil
    hospital.save
    hospital_names << hospital.name
    hospital_ids[hospital.name] = hospital.id
  else
    existing_hospital = Hospital.get(hospital_ids[hospital.name])
    existing_hospital.occurrences += hospital.occurrences
    existing_hospital.save
    hospital = existing_hospital
  end

  if hospital.occurrences != nil and hospital.occurrences < min_occurrences
    min_occurrences = hospital.occurrences
  end
  if hospital.occurrences != nil and hospital.occurrences > max_occurrences
    max_occurrences = hospital.occurrences
  end
end

# Set min and max occurrences for each record that was inserted
min_occurrences = 0 if min_occurrences != Integer::MAX
hospitals = Hospital.all({'rating_criteria': 'mortality', 'procedure': nil, 'county': nil})
hospitals.each do |hospital|
  hospital.min_occurrences = min_occurrences
  hospital.max_occurrences = max_occurrences
  set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
end









#
#
# Ingest Central Line-Associated Bloodstream Infections (CLABSI)
#
#
min_occurrences = Integer::MAX
max_occurrences = 0
counties.each do |county|
  puts
  puts "#{county} CLABSI -----------------------------"
  puts

  client = SODA::Client.new({:domain => "cdph.data.ca.gov"})
  soda_response = client.get("m9uu-yhtz", {"county": county})

  #puts soda_response.to_s

  soda_response.each do |record|
    facility_name = record['facility_name1']
    occurrences = record['observed_infections']
    out_of = nil
    puts "County #{record['county']}"
    puts "Facility #{facility_name}"
    puts "Occurrences #{occurrences}"
    puts "Out of #{out_of}"
    puts

    hospital = Hospital.new
    hospital.name = facility_name
    hospital.county = county
    hospital.rating_criteria = 'CLABSI'
    hospital.occurrences = occurrences
    hospital.occurrences = 0 if hospital.occurrences.nil?
    hospital.out_of = out_of
    hospital.out_of = 0 if hospital.out_of.nil?
    hospital.save

    if hospital.occurrences != nil and hospital.occurrences < min_occurrences
      min_occurrences = hospital.occurrences
    end
    if hospital.occurrences != nil and  hospital.occurrences > max_occurrences
      max_occurrences = hospital.occurrences
    end
  end
end

# Set min and max occurrences for each record that was inserted
min_occurrences = 0 if min_occurrences != Integer::MAX
hospitals = Hospital.all()
hospitals.each do |hospital|
  hospital.min_occurrences = min_occurrences
  hospital.max_occurrences = max_occurrences
  set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
end



# Generate rating_type, county, procedure = nil
counties.each do |county|
  min_occurrences = Integer::MAX
  max_occurrences = 0
  hospital_names = []
  hospital_ids = {}

  puts "Creating hospitals for rating_criteria: CLABSI county #{county}"
  hospitals = Hospital.all({'rating_criteria': 'CLABSI', 'county': county})
  hospitals.each do |hospital|
    if not hospital_names.include? hospital.name
      hospital = Hospital.new hospital
      hospital.procedure = nil
      hospital.save
      hospital_names << hospital.name
      hospital_ids[hospital.name] = hospital.id
    else
      existing_hospital = Hospital.get(hospital_ids[hospital.name])
      existing_hospital.occurrences += hospital.occurrences
      existing_hospital.save
      hospital = existing_hospital
    end

    if hospital.occurrences != nil and hospital.occurrences < min_occurrences
      min_occurrences = hospital.occurrences
    end
    if hospital.occurrences != nil and hospital.occurrences > max_occurrences
      max_occurrences = hospital.occurrences
    end
  end

  # Set min and max occurrences for each record that was inserted
  min_occurrences = 0 if min_occurrences != Integer::MAX
  hospitals = Hospital.all({'rating_criteria': 'CLABSI', 'county': county, 'procedure': nil})
  hospitals.each do |hospital|
    hospital.min_occurrences = min_occurrences
    hospital.max_occurrences = max_occurrences
    set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
  end
end




# Generate rating_type, procedure = nil, county = nil
min_occurrences = Integer::MAX
max_occurrences = 0
hospital_names = []
hospital_ids = {}

puts "Creating hospitals for rating_criteria: CLABSI, No county, No procedure"
hospitals = Hospital.all({'rating_criteria': 'CLABSI'})
hospitals.each do |hospital|
  if not hospital_names.include? hospital.name
    hospital = Hospital.new hospital
    hospital.procedure = nil
    hospital.county = nil
    hospital.save
    hospital_names << hospital.name
    hospital_ids[hospital.name] = hospital.id
  else
    existing_hospital = Hospital.get(hospital_ids[hospital.name])
    existing_hospital.occurrences += hospital.occurrences
    existing_hospital.save
    hospital = existing_hospital
  end

  if hospital.occurrences != nil and hospital.occurrences < min_occurrences
    min_occurrences = hospital.occurrences
  end
  if hospital.occurrences != nil and hospital.occurrences > max_occurrences
    max_occurrences = hospital.occurrences
  end
end

# Set min and max occurrences for each record that was inserted
min_occurrences = 0 if min_occurrences != Integer::MAX
hospitals = Hospital.all({'rating_criteria': 'CLABSI', 'procedure': nil, 'county': nil})
hospitals.each do |hospital|
  hospital.min_occurrences = min_occurrences
  hospital.max_occurrences = max_occurrences
  hospital.out_of = max_occurrences
  set_hospital_display_percentage(hospital, min_occurrences, max_occurrences)
end







# #
# #
# # Ingest Methicillin-Resistant Staphylococcus Aureus (MRSA)
# #
# #
# min_occurrences = Integer::MAX
# max_occurrences = 0
# procedures = []
# counties.each do |county|
#   puts
#   puts "#{county} MRSA -----------------------------"
#   puts
#
#   # Surgical Site Infections MRSA
#   client = SODA::Client.new({:domain => "cdph.data.ca.gov"})
#   soda_response = client.get("bnzh-iyt4", {"county": county})
#
#   # puts soda_response.to_s
#
#   soda_response.each do |record|
#     procedure_name = record['operative_procedure'].strip
#     procedure = Procedure.all(name: procedure_name).first
#     if procedure.nil?
#       procedure = Procedure.new
#       procedure.name = procedure_name
#       procedure.save
#     end
#
#     if not procedures.include? procedure.name
#       procedures << procedure.name
#     end
#   end
#
#   soda_response.each do |record|
#     procedure_name = record['operative_procedure']
#     facility_name = record['facility_name1']
#     occurrence = record['']
#     out_of = record['']
#     puts "County #{record['county']}"
#     puts "Facility #{facility_name}"
#     puts "Infection Count #{occurrence}"
#     puts "Out of Count #{out_of}"
#     puts "Procedure #{procedure_name}"
#     puts
#
#     hospital = Hospital.new
#     hospital.name = facility_name
#     hospital.procedure = procedure_name
#     hospital.county = county
#     hospital.rating_criteria = 'MRSA'
#     hospital.occurrences = occurrence
#     hospital.occurrences = 0 if hospital.occurrences.nil?
#     hospital.out_of = out_of
#     hospital.out_of = 0 if hospital.out_of.nil?
#     hospital.save
#
#     if hospital.occurrences != nil and hospital.occurrences < min_occurrences
#       min_occurrences = hospital.occurrences
#     end
#     if hospital.occurrences != nil and  hospital.occurrences > max_occurrences
#       max_occurrences = hospital.occurrences
#     end
#
#     # Add to the global list of procedures that'll be used in procedure dropdowns
#     procedure = Procedure.all(name: procedure_name).first
#     if procedure.nil?
#       procedure = Procedure.new
#       procedure.name = procedure_name
#       procedure.save
#     end
#   end
# end
#
# # Set min and max occurrences for each record that was inserted
# hospitals = Hospital.all()
# hospitals.each do |hospital|
#   if min_occurrences != Integer::MAX
#     hospital.min_occurrences = min_occurrences
#   else
#     hospital.min_occurrences = 0
#   end
#
#   hospital.max_occurrences = max_occurrences
#   hospital.save
# end
#
#
#
# # Generate rating_type, procedure, county = nil
# procedures.each do |procedure|
#   min_occurrences = Integer::MAX
#   max_occurrences = 0
#   hospital_names = []
#   hospital_ids = {}
#
#   puts "Creating hospitals for rating_criteria: MRSA procedure #{procedure}"
#   hospitals = Hospital.all({'rating_criteria': 'MRSA', 'procedure': procedure})
#   hospitals.each do |hospital|
#     if not hospital_names.include? hospital.name
#       hospital = Hospital.new hospital
#       hospital.county = nil
#       hospital.save
#       hospital_names << hospital.name
#       hospital_ids[hospital.name] = hospital.id
#     else
#       existing_hospital = Hospital.get(hospital_ids[hospital.name])
#       existing_hospital.occurrences += hospital.occurrences
#       existing_hospital.save
#       hospital = existing_hospital
#     end
#
#     if hospital.occurrences != nil and hospital.occurrences < min_occurrences
#       min_occurrences = hospital.occurrences
#     end
#     if hospital.occurrences != nil and  hospital.occurrences > max_occurrences
#       max_occurrences = hospital.occurrences
#     end
#   end
#
#   # Set min and max occurrences for each record that was inserted
#   hospitals = Hospital.all({'rating_criteria': 'MRSA', 'procedure': procedure, 'county': nil})
#   hospitals.each do |hospital|
#     if min_occurrences != Integer::MAX
#       hospital.min_occurrences = min_occurrences
#     else
#       hospital.min_occurrences = 0
#     end
#
#     hospital.max_occurrences = max_occurrences
#     hospital.save
#   end
# end
#
#
#
# # Generate rating_type, county, procedure = nil
# counties.each do |county|
#   min_occurrences = Integer::MAX
#   max_occurrences = 0
#   hospital_names = []
#   hospital_ids = {}
#
#   puts "Creating hospitals for rating_criteria: MRSA county #{county}"
#   hospitals = Hospital.all({'rating_criteria': 'MRSA', 'county': county})
#   hospitals.each do |hospital|
#     if not hospital_names.include? hospital.name
#       hospital = Hospital.new hospital
#       hospital.procedure = nil
#       hospital.save
#       hospital_names << hospital.name
#       hospital_ids[hospital.name] = hospital.id
#     else
#       existing_hospital = Hospital.get(hospital_ids[hospital.name])
#       existing_hospital.occurrences += hospital.occurrences
#       existing_hospital.save
#       hospital = existing_hospital
#     end
#
#     if hospital.occurrences != nil and hospital.occurrences < min_occurrences
#       min_occurrences = hospital.occurrences
#     end
#     if hospital.occurrences != nil and hospital.occurrences > max_occurrences
#       max_occurrences = hospital.occurrences
#     end
#   end
#
#   # Set min and max occurrences for each record that was inserted
#   hospitals = Hospital.all({'rating_criteria': 'MRSA', 'county': county, 'procedure': nil})
#   hospitals.each do |hospital|
#     if min_occurrences != Integer::MAX
#       hospital.min_occurrences = min_occurrences
#     else
#       hospital.min_occurrences = 0
#     end
#
#     hospital.max_occurrences = max_occurrences
#     hospital.save
#   end
# end
#
#
#
#
# # Generate rating_type, procedure = nil, county = nil
# min_occurrences = Integer::MAX
# max_occurrences = 0
# hospital_names = []
# hospital_ids = {}
#
# puts "Creating hospitals for rating_criteria: MRSA, No county, No procedure"
# hospitals = Hospital.all({'rating_criteria': 'MRSA'})
# hospitals.each do |hospital|
#   if not hospital_names.include? hospital.name
#     hospital = Hospital.new hospital
#     hospital.procedure = nil
#     hospital.county = nil
#     hospital.save
#     hospital_names << hospital.name
#     hospital_ids[hospital.name] = hospital.id
#   else
#     existing_hospital = Hospital.get(hospital_ids[hospital.name])
#     existing_hospital.occurrences += hospital.occurrences
#     existing_hospital.save
#     hospital = existing_hospital
#   end
#
#   if hospital.occurrences != nil and hospital.occurrences < min_occurrences
#     min_occurrences = hospital.occurrences
#   end
#   if hospital.occurrences != nil and hospital.occurrences > max_occurrences
#     max_occurrences = hospital.occurrences
#   end
# end
#
# # Set min and max occurrences for each record that was inserted
# hospitals = Hospital.all({'rating_criteria': 'MRSA', 'procedure': nil, 'county': nil})
# hospitals.each do |hospital|
#   if min_occurrences != Integer::MAX
#     hospital.min_occurrences = min_occurrences
#   else
#     hospital.min_occurrences = 0
#   end
#
#   hospital.max_occurrences = max_occurrences
#   hospital.save
# end
#










