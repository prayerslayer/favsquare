class Favsquare

	module Views

		class Create < Layout

			def title
				"Create sets on Soundcloud"
			end

			def num_tracks
				FavsquareLogic.get_playlist_size( @session[ :user_id ] )
			end
		end
	end

end