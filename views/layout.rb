class Favsquare

	module Views

		class Layout < Mustache

			def hello_message
				if @session[:user_name] != nil
					"Hello, " + @session[:user_name] + "!"
				else
					""
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
					"Log you out?"
				else
					""
				end
			end
		end
	end

end