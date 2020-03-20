# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "geocoder"
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################bun

places_table = DB.from(:places)
comment_table = DB.from(:comment)
users_table = DB.from(:users)

# put your API credentials here (found on your Twilio dashboard)
account_sid = ENV["TWILIO_ACCOUNT_SID"]
auth_token = ENV["TWILIO_AUTH_TOKEN"]

# set up a client to talk to the Twilio REST API
client = Twilio::REST::Client.new(account_sid, auth_token)

# User ID to get the current user
before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts places_table.all
    @places = places_table.all.to_a
    view "places"
end

get "/places/:id" do
    @place = places_table.where(id: params[:id]).to_a[0]
    @comment = comment_table.where(place_id: @place[:id])
    @users_table = users_table

    results = Geocoder.search(@place[:restaurant])
    @lat_lng = results.first.coordinates
    @lat = @lat_lng[0]
    @lng = @lat_lng[1]
    @lat_long = "#{@lat},#{@lng}"

    view "place"
end

get "/places/:id/comment/new" do
    @place = places_table.where(id: params[:id]).to_a[0]
    view "new_comment"
end

get "/places/:id/comment/create" do
    puts params
    @place = places_table.where(id: params["id"]).to_a[0]
    comment_table.insert(place_id: params["id"],
                       user_id: session["user_id"],
                       visited: params["visited"],
                       comments: params["comments"])


    # send the SMS from your trial Twilio number to your verified non-Twilio number
    client.messages.create(
        from: "+12057546117", 
        to: "+12244324570",
        body: "Thank you for leaving your comment in Alex's Chicago 101"
    )

    view "create_comment"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts "params: #{params}"
    user = users_table.where(email: params["email"]).to_a[0]
        
    if user
        if BCrypt::Password.new(user[:password]) == params["password"]
            session["user_id"] = user[:id]
            @current_user = user
            view "login_success"
        else
            view "login_failed"
        end
    else
        view "login_failed"
    end

end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end

