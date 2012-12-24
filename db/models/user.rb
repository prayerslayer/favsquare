require "digest/sha2"
require "sequel"
require "pony"
require "soundcloud"
require "date"

class User < Sequel::Model
	many_to_many :tracks, :join_table => :user_tracks

	attr_accessor :username

	def playlist_size
		size = self.tracks.count
		split = size/500 + ( size % 500 > 0 ? 1 : 0 )
		textsplit = split == 1 ? "set" : "sets"
		textsize = size == 1 ? "track" : "tracks"
		return { :size => size.to_s + " " + textsize, :split => split.to_s + " " + textsplit }
	end

	def username
		if @username == nil
			client = Soundcloud.new( :access_token => self.token )
			@username = client.get( "/me" )[:username].to_s
		end
		return @username
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
			return false
		end
		return true
	end

	def self.update_tracks( user_id )

		user = filter( :user_id => user_id ).first
		favs = SoundcloudHelper.fetch_favs( user.token )

		# update tracks
		sc_track_ids = favs.keys.clone
		track_ids = user.tracks.collect { |t| t[ :track_id] }

		# remove duplicates in arrays
		sc_track_ids = sc_track_ids.uniq
		track_ids = track_ids.uniq

		same_tracks = sc_track_ids & track_ids 	# array intersection - these tracks will be kept
		tracks_to_add = sc_track_ids - same_tracks # array difference - these tracks need to be added
		tracks_to_remove = track_ids - sc_track_ids # array difference - these tracks will get deleted
		
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

				favgiver = SoundcloudHelper.fetch_user_info( user.token, fav.faved_by )
				pl_track.faved_by = favgiver.username
				pl_track.faved_by_profile = favgiver.permalink_url

				pl_track.save
			else
				# track exists, add it to user
				Track.filter( :track_id => track ).first.add_user( user )
			end
		end
		Track.restrict_primary_key

		# TODO update existing (re-fetch)

		# remove old
		if !user.tracks.empty?
			user.tracks.each do |track|
				if tracks_to_remove.include?( track[ :track_id ] )
					user.remove_track( track )
				end
			end
		end

		# finished! send email.
		# re-fetch since it may be added after start of function
		user = filter( :user_id => user_id ).first
		user.send_mail( "Rain: Listen now", "Yeah" )
	end

	def send_mail( subject, body )
		if self.email != nil
			Pony.mail :to => self.email,
					:from => "rainapp.hello@gmail.com",
		            :subject => subject,
		            :html_body => body,
		            :via => :smtp,
					:via_options => {
						:address              => 'smtp.gmail.com',
						:port                 => '587',
						:enable_starttls_auto => true,
						:user_name            => 'rainapp.hello',
						:password             => 'scotchtravis',
						:authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
						:domain               => "obscure-basin-1623.herokuapp.com" # the HELO domain provided by the client to the server
					}
			self.update( :email => nil )
		else
			$LOG.debug( "Unable to send - Email is nil" )
		end
	end

	def get_playlist_tracks( amount )
		# sort tracks ascending 
		tracks = self.tracks.shuffle.sort{ |a,b| UserTrack.filter( :track_id => a.track_id, :user_id => self.user_id).first.times_served <=> UserTrack.filter( :track_id => b.track_id, :user_id => self.user_id).first.times_served }
		# take the first amount much
		tracks = tracks.take( amount ).shuffle

		$LOG.debug( tracks.collect{|t| t[:track_id]}.to_s )

		# update times served variable
		full_tracks = []
		tracks.each do |track|
			# times served ++
			usr_track = UserTrack.filter( :track_id => track.track_id, :user_id => self.user_id ).first
			$LOG.debug( usr_track.times_served.to_s )
			usr_track.times_served += 1
			usr_track.save

			# "join"
			full_tracks << track.values.merge( usr_track.values )
		end
		$LOG.debug( full_tracks )
		return full_tracks
	end
end