require "sinatra/base"
require "sinatra/session"
require "soundcloud"

class Favsquare

	module Views

		class Playlist < Layout

			def tracks

			end

			def followings
				client = Soundcloud.new( :access_token => @session[ :token ] )
				client.get( "/me/followings" )

			end

		end

	end

end