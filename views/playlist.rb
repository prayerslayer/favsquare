require "sinatra/base"
require "sinatra/session"
require "soundcloud"

class Favsquare

	module Views

		class Playlist < Layout

			def tracks
				client = Soundcloud.new( :access_token => @session[ :token ] )
				# get own favs
				favs = client.get( "/me/favorites" )
				# get other favs
				followings = client.get( "/me/followings" )
				followings.each do |following|
					favs << client.get( "/users/"+following.id.to_s+"/tracks" )
				end

				favs
				
			end

			def followings
				client = Soundcloud.new( :access_token => @session[ :token ] )
				client.get( "/me/followings" )

			end

		end

	end

end