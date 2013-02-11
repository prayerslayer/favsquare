require "net/http"
require "digest/sha2"
require "sequel"
require "pony"
require "soundcloud"
require "date"

production = ENV['RACK_ENV'] == "production"

if production then
	require "./herokuconnection.rb"
end

class User < Sequel::Model
	many_to_many :tracks, :join_table => :user_tracks

	def playlist_size
		size = self.tracks.count
		split = size/500 + ( size % 500 > 0 ? 1 : 0 )
		textsplit = split == 1 ? "set" : "sets"
		textsize = size == 1 ? "track" : "tracks"
		return { :size => size.to_s + " " + textsize, :split => split.to_s + " " + textsplit }
	end

	def self.id_for( sc_id )
		raise ArgumentError, "User ID is nil!" if sc_id == nil
		id = Digest::SHA512.new << sc_id.to_s
		return id.to_s
	end

	def self.create_user( sc_id )
		raise ArgumentError, "User ID is nil!" if sc_id == nil
		
		new_user = nil
		user_id = User.id_for( sc_id )
		if !User.exists?( sc_id )

			User.unrestrict_primary_key

			new_user = User.create( :user_id => user_id )
			new_user.save

			User.restrict_primary_key
		else
			new_user = User.filter( :user_id => user_id ).first
		end
		return new_user
	end

	def self.exists?( sc_id )
		raise ArgumentError, "User ID is nil!" if sc_id == nil

		# hash user id
		user_id = self.id_for( sc_id )

		return User.filter( :user_id => user_id ).first != nil
	end

	def create_set()
		set_name = "Rain on " + DateTime.now.strftime( "%m/%d/%Y" )
		tracks = self.tracks.collect {|track| { :id => track[:track_id] } }
		client = Soundcloud.new( :access_token => self.token )
		iterations = 1
		begin
			begin
				client.post( "/playlists", :playlist => {
					:title => set_name + ( iterations == 1 && tracks.size < 500 ? "" : " #"+iterations.to_s ),
					:tracks => tracks.slice!( 0, 500 )
				})
				iterations += 1
			end while tracks.size > 0
		rescue Soundcloud::ResponseError => error
			puts error.response
		rescue Net::HTTPServerError => timeout
			puts timeout.response
		end
		return true
	end

	def self.update_tracks( user_id )
		puts "Wait for heroku worker"
		sleep 10
		puts "Get user"
		user = filter( :user_id => user_id ).first
		favs = FavsquareHelper::SoundcloudHelper.fetch_favs( user.token )
		puts "Fetch tracks"
		# update tracks
		sc_track_ids = favs.keys.clone
		track_ids = user.tracks.collect { |t| t[ :track_id] }

		# remove duplicates in arrays
		sc_track_ids = sc_track_ids.uniq
		track_ids = track_ids.uniq

		same_tracks = sc_track_ids & track_ids 	# array intersection - these tracks will be kept
		tracks_to_add = sc_track_ids - same_tracks # array difference - these tracks need to be added
		tracks_to_remove = track_ids - sc_track_ids # array difference - these tracks will get deleted
		puts "Add tracks"
		# add new
		Track.unrestrict_primary_key
		tracks_to_add.each do |track|
			# check if track exists
			if Track.filter( :track_id => track ).empty?
				# if not, add track
				fav = favs[track]
				puts "adding track " + track.to_s
				new_track = Track.create( {
					:track_id => fav.id,
					:title => fav.title,
					:waveform_url => fav.waveform_url,
					:duration => fav.duration,
					:creator_id => fav.user.id,
					:creator => fav.user.username,
					:creator_profile => fav.user.permalink_url,
					:creator_avatar => fav.user.avatar_url
				} )
				new_track.add_user( user )
				new_track.save

				# add additional information
				pl_track = UserTrack.filter( :user_id => user.user_id, :track_id => track ).first
				pl_track.faved_by_id = fav.faved_by

				favgiver = FavsquareHelper::SoundcloudHelper.fetch_user_info( user.token, fav.faved_by )
				pl_track.faved_by = favgiver.username
				pl_track.faved_by_profile = favgiver.permalink_url

				pl_track.save
			else
				# track exists, add it to user
				Track.filter( :track_id => track ).first.add_user( user )
			end
		end
		Track.restrict_primary_key
		puts "update existing tracks"
		# update existing tracks
		same_tracks.each do |track|
			fav = favs[track]
			db_track = Track.filter( :track_id => track )
			db_track.keys.each do |key|
				# != nil to prevent sequel from trying to save other attributes
				if db_track[key] != fav[key] then
					db_track[key] = fav[key]
				end
			end
			db_track.save_changes
			puts "udpated track " + track.to_s
		end
		puts "Remove old tracks"
		# remove old
		if !user.tracks.empty? then
			user.tracks.each do |track|
				if tracks_to_remove.include?( track[ :track_id ] )
					user.remove_track( track )
				end
			end
		end
		puts "Send email"
		# finished! send email.
		# re-fetch since it may be added after start of function
		begin 
			user = filter( :user_id => user_id ).first
			user.send_mail( "Rain: Listen now", "<a href='" + ENV['BASE_URL'] + "/playlist'>Listen.</a>" )
		rescue StandardError => e
			puts "Something went wrong while sending email."
		end
		# now check if we need to fire heroku worker
		if ENV['RACK_ENV'] == "production" then
			# <= 1 because we are still running this job
			if Navvy::Job.filter( :completed_at => nil, :failed_at => nil ).count <= 1 then
				# fire worker
				puts "No more jobs!"
				FavsquareHelper::HerokuConnection.init()
				FavsquareHelper::HerokuConnection.fire_worker()
			end
		end
	end

	def send_mail( subject, body )
		if self.email != nil then
			Pony.mail :to => self.email,
					:from => ENV['EMAIL_FROM'],
		            :subject => subject,
		            :html_body => body,
		            :via => :smtp,
					:via_options => {
						:address              => ENV['EMAIL_SERVER'],
						:port                 => ENV['EMAIL_PORT'],
						:enable_starttls_auto => true,
						:user_name            => ENV['EMAIL_USER'],
						:password             => ENV['EMAIL_PWD'],
						:authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
						:domain               => ENV['EMAIL_DOMAIN'] # the HELO domain provided by the client to the server
					}
			puts "Send mail"
			self.update( :email => nil )
			puts "Deleted address"
		else
			puts "Unable to send - Email is nil" 
		end
	end

	def get_playlist_tracks( amount )
		# sort tracks ascending 
		tracks = self.tracks.shuffle.sort{ |a,b| UserTrack.filter( :track_id => a.track_id, :user_id => self.user_id).first.times_served <=> UserTrack.filter( :track_id => b.track_id, :user_id => self.user_id).first.times_served }
		# take the first amount much
		tracks = tracks.take( amount ).shuffle

		# puts tracks.collect{|t| t[:track_id]}.to_s

		# update times served variable
		full_tracks = []
		tracks.each do |track|
			# times served ++
			usr_track = UserTrack.filter( :track_id => track.track_id, :user_id => self.user_id ).first
			usr_track.times_served += 1
			usr_track.save

			# "join"
			full_track = track.values.merge( usr_track.values )
			full_track[:id] = full_track[:track_id].to_s + full_track[:times_served].to_s
			full_tracks << full_track
		end
		return full_tracks
	end
end