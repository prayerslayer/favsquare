require "sinatra/base"
require "sinatra/session"
require "soundcloud"

class Favsquare

	module Views

		class Playlist < Layout

			def tracks
				client = Soundcloud.new( :access_token => @session[ :token ] )
				# get followings
				followings = client.get( "/me/followings" )
				favs = []
				# get favorites
				for follower in followings
					favs.join( client.get( "/user/"+follower.id+"/favorites" ) )
				end
			end

		end

	end

end