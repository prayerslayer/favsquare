# encoding: utf-8

class Favsquare

	module Views

		class Update < Layout

			def title
				"Updating information"
			end

			def show_email
				@session[:user_email] == nil
			end

		end
	end

end