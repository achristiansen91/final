# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :places do
  primary_key :id
  String :neighborhood
  String :description, text: true
  String :distance
  String :restaurant
  String :bar
  String :coffee
end
DB.create_table! :comment do
  primary_key :id
  foreign_key :place_id
  foreign_key :user_id
  Boolean :visited
  String :comments, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
places_table = DB.from(:places)

places_table.insert(neighborhood: "Lincoln Park", 
                    description: "Tree-lined Lincoln Park offers diverse nightlife, dining and entertainment. North Lincoln Avenue features cocktail lounges, dive bars and concert venues such as Lincoln Hall. The revered Steppenwolf Theatre Company is on Halstead Street. Comedy clubs Up and Second City sit on the border with Old Town. Within the shoreline park are North Avenue Beach, the Chicago History Museum and the free-admission Lincoln Park Zoo",
                    distance: "9 miles", 
                    restaurant: "Cafe Ba-Ba-Reeba!",
                    bar: "Kingston Mines",
                    coffee: "CityGrounds Coffee Bar")

places_table.insert(neighborhood: "Wicker Park", 
                    description: "Hip Wicker Park has been a residential enclave since Chicago was incorporated as a city in 1837. North Milwaukee Avenue is known for its bustling nightlife, dining and entertainment venues, with Double Door, Subterranean and Davenport’s setting the bar for the city's trendy music clubs. North Damen Avenue draws hip crowds with its quirky shops, minimalist cafes, specialty grocery stores and cool fashion boutiques",
                    distance: "10 miles", 
                    restaurant: "Small Cheval",
                    bar: "The Violet Hour",
                    coffee: "Philz Coffee")

places_table.insert(neighborhood: "West Loop", 
                    description: "A former industrial zone, the hip West Loop is now a dining and nightlife hotspot. Inventive New American and global eateries line Restaurant Row, and the French Market food hall hosts local vendors. Pubs, bars, and live music venues dot the area, as do upscale boutiques, while Randolph Street Market sells vintage wares one weekend a month. The grand Union Station, built in 1925, is an iconic beaux arts rail hub",
                    distance: "14 miles", 
                    restaurant: "The Girl & the Goat",
                    bar: "The Aviary",
                    coffee: "Limitless Coffee & Tea")

puts "Sucess!"
