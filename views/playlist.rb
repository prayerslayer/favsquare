require "sinatra/base"
require "sinatra/session"
require "soundcloud"
require "sequel"

class Favsquare

	module Views

		class Playlist < Layout

			def title
				"Your playlist"
			end

		end

	end

end