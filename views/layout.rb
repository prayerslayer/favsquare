class Favsquare

	module Views

		class Layout < Mustache

			def visibility
				if @session[:user_name] != nil
					"block"
				else
					"none"
				end
			end

			def overview_message
				if @session[:user_name] != nil
					"Who to follow on SC"
				else
					nil
				end
			end

			def playlist_message
				if @session[:user_name] != nil
					"Playlist"
				else
					nil
				end
			end

			def create_message
				if @session[:user_name] != nil
					"Create set on SC"
				else
					nil
				end
			end

			def login_message
				if @session[:user_name] == nil
					"Login"
				else
					"Logout"
				end
			end

			def login_url
				if @session[:user_name] == nil
					"/login"
				else
					"/logout"
				end
			end
		end
	end

end