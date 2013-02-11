require "heroku-api"

module FavsquareHelper
	class HerokuConnection
		@@api = nil
		@@worker = 0

		# singleton for api connection
		def self.init
			# if there is no api connection yet
			if @@api == nil
				# then init api connection
				if ENV['HEROKU_API_KEY'] != nil
					puts "Connect to Heroku using API key"
					@@api = Heroku::API.new( :api_key => ENV['HEROKU_API_KEY'] )
				else
					puts "Connect to Heroku using username/pwd"
					@@api = Heroku::API.new( :username => ENV['HEROKU_USERNAME'], :password => ENV['HEROKU_PASSWORD'] )
				end
				puts ENV['HEROKU_APP']
				# then init worker count
				@@worker = 0
				response = @@api.get_ps( ENV['HEROKU_APP'].to_s )
				if ( response.status == 200 )
					processes = response.body
					processes.each do |proc|
						if ( proc["process"].start_with?( "worker") )
							@@worker = @@worker + 1
						end
					end
				end
				puts "Worker count at start = " + @@worker.to_s
			end		
		end
		
		def self.worker_count
			@@worker
		end

		def self.hire_worker
			@@worker = 1
			@@api.post_ps_scale( ENV['HEROKU_APP'], "worker",  @@worker.to_s )
			puts "Hired a worker."
		end

		def self.fire_worker
			@@worker = 0
			@@api.post_ps_scale( ENV['HEROKU_APP'], "worker", @@worker.to_s )
			puts "Fired the worker."
		end

		def self.is_fired?
			return @@worker == 0
		end

		def self.is_hired?
			return @@worker == 1
		end

	end
end