require "soundcloud"

class Favsquare

	enable :sessions

	module Views

		class Playlist < Layout

			def tracks
				#client = Soundcloud.new( :access_token => session[ :token ])
				#client.get("/me/tracks")
			end

		end

	end

end