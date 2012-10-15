require "digest/sha2"
require "sequel"
require "soundcloud"

class User < Sequel::Model
	many_to_many :tracks, :join_table => :user_tracks

	attr_accessor :username

	def playlist_size
		size = self.tracks.count
		split = size/500 + ( size % 500 > 0 ? 1 : 0 )
		return { :size => size, :split => split }
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

	def get_missing_followings

		# TODO umschreiben ohne netzwerkzugriffe

		followings = SoundcloudHelper.fetch_followings( self.token )
		favs = SoundcloudHelper.fetch_favs( self.token )
		# get artists of those favs
		artists = []
		favs.values.each do |fav|
			artists << fav.user
		end
		
		# count each artist
		artist_count = {}
		artists.each do |artist|
			if !followings.include?( artist.id )
				artist_count[ artist.permalink ] = artist_count[ artist.permalink ] == nil ? 1 : artist_count[ artist.permalink ] + 1
			end
		end

		# transform in regular json object
		json = []
		artist_count.each do |artist, count|
			json << { :artist => artist, :count => count }
		end
		return json
	end

	def create_set( set_name )
		tracks = self.tracks.collect {|track| { :id => track[:track_id] } }
		client = Soundcloud.new( :access_token => self.token )
		iterations = 1
		begin
			begin
				client.post( "/playlists", :playlist => {
					:title => set_name + ( iterations == 1 ? "" : " "+iterations.to_s ),
					:tracks => tracks.slice!( 0, 499 )
				})
				iterations += 1
			end while tracks.size > 500
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
				puts "updating track " + track.to_s
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
		# remove old
		if !user.tracks.empty?
			user.tracks.each do |track|
				if tracks_to_remove.include?( track[ :track_id ] )
					user.remove_track( track )
				end
			end
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