require "sinatra"
require "sinatra/reloader"
require "http"
require "json"

get("/") do
  erb(:home)
end

get("/chat") do
  erb(:chat)
end

get("/umbrella") do
  erb(:umbrella)
end

post("/process_umbrella") do
  @user_location = params.fetch("user_loc")

  gmaps_key = ENV["GMAPS_KEY"]

  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@user_location}&key=#{gmaps_key}"

  @raw_response = HTTP.get(gmaps_url).to_s

  parsed_response = JSON.parse(@raw_response)

  loc_hash = parsed_response.dig("results", 0, "geometry", "location")

  if loc_hash == nil
    abort("Location not found")
  end
  
  @latitude = loc_hash.fetch("lat")
  @longitude = loc_hash.fetch("lng")

  weather_key = ENV["PIRATE_WEATHER_KEY"]

  weather_url = "https://api.pirateweather.net/forecast/#{weather_key}/#{@latitude},#{@longitude}"

  weather_res = HTTP.get(weather_url).to_s

  parsed_weather = JSON.parse(weather_res)

  current_hash = parsed_weather.fetch("currently")

  @current_temp = current_hash.fetch("temperature").round(2)

  @current_summary = current_hash.fetch("summary")

  @umbrella = false

  case @current_summary
  when "Rain", "Snow", "Sleet", "Cloudy"
    @umbrella = true
  end
  
  erb(:umbrella_results)
end

get("/message") do
  erb(:message)
end

post("/process_message") do
  @message = params["message"]

  request_headers_hash = {
    "Authorization" => "Bearer: #{ENV["OPEN_API_KEY"]}",
    "content-type" => "application/json"
  }

  request_body_hash = {
    "model" => "gpt-3.5-turbo",
    "messages" => [
      {
        "role" => "system",
        "content" => "You are a helpful assistant who talks like Shakespeare."
      },
      {
        "role" => "user",
        "content" => @message
      }
    ]
  }

  request_body_json = JSON.generate(request_body_hash)

  raw_response = HTTP.headers(request_headers_hash).post("https://api.openai.com/v1/chat/completions", :body => request_body_json).to_s

  @parsed_response = JSON.parse(raw_response)

  erb(:message_results)
end
