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
					"Listen now"
				else
					nil
				end
			end

			def create_message
				if @session[:user_id] != nil
					"Create set"
				else
					nil
				end
			end

			def login_message
				if @session[:user_id] == nil
					"Connect"
				else
					"Sign out"
				end
			end

			def login_url
				if @session[:user_id] == nil
					"/login"
				else
					"/logout"
				end
			end

			def login_icon
				if @session[:user_id] == nil
					"signin"
				else
					"signout"
				end
			end
		end
	end

end