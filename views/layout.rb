class Favsquare

	module Views

		class Layout < Mustache

			def visibility
				if @session[:user_id] != nil
					"block"
				else
					"none"
				end
			end

			def overview_message
				if @session[:user_id] != nil
					"Who to follow on SC"
				else
					nil
				end
			end

			def playlist_message
				if @session[:user_id] != nil
					"Playlist"
				else
					nil
				end
			end

			def create_message
				if @session[:user_id] != nil
					"Create set on SC"
				else
					nil
				end
			end

			def login_message
				if @session[:user_id] == nil
					"Login"
				else
					"Logout"
				end
			end

			def login_url
				if @session[:user_id] == nil
					"/login"
				else
					"/logout"
				end
			end
		end
	end

end