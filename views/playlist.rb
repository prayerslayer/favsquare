require "sinatra/base"
require "sinatra/session"
require "soundcloud"
require "sequel"

class Favsquare

	module Views

		class Playlist < Layout

			def user
				User.filter( :sc_user_id => @session[ :user_id ]).first.user_id
			end

			def tracks

			end

			def title
				"Your playlist"
			end

			def followings
				client = Soundcloud.new( :access_token => @session[ :token ] )
				client.get( "/me/followings" )

			end

		end

	end

end