require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

get("/") do
  "
  <h1>Welcome to your Sinatra App!</h1>
  <p>Define some routes in app.rb</p>
  "
end

get("/chat") do

end

get("/umbrella") do
  erb(:umbrella)
end

get("/process_umbrella") do
  @user_location = params.fetch("user_loc")

  gmaps_key = ENV["GMAPS_KEY"]

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@user_location}&key=#{gmaps_key}"

  @raw_response = HTTP.get(gmaps_url).to_s

  parsed_response = JSON.parse(@raw_response)

  loc_hash = parsed_response.dig("results", 0, "geometry", "location")
  
  @latitude = loc_hash.fetch("lat")
  @longitude = loc_hash.fetch("lng")
  
  erb(:umbrella_results)
end

get ("/message") do

end
