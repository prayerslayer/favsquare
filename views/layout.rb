class Favsquare

	module Views

		class Layout < Mustache

			def hello_message
				if @session[:user_name] != nil
					"Hello, " + @session[:user_name] + "!"
				else
					"Hello, stranger!"
				end
			end

			def profile_url
				if @session[ :user_name ] != nil
					"http://soundcloud.com/" + @session[ :user_name ]
				else
					"http://soundcloud.com"
				end
			end

			def login_message
				if @session[:user_name] == nil
					"Login"
				else
					""
				end
			end

			def logout_message
				if @session[:user_name] != nil
					"Logout"
				else
					""
				end
			end
		end
	end

end