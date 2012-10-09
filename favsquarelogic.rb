require "digest/sha2"
require "sequel"
require "./soundcloudhelper"

# class encapsulating what the application actually does

class FavsquareLogic

	# creates a user
	# IN user id at soundcloud
	# OUT local user id ( SHA-512 hash )
	def self.create_user( sc_user_id )
		raise ArgumentError, "User ID is nil!" if sc_user_id == nil

		user_id = self.get_id_for( sc_user_id )
		new_user = User.create( :user_id => user_id )
		new_user.save
		return user_id
	end

	# soundcloud user id -> own user id
	# IN user id at soundcloud
	# OUT SHA-512( user id )
	def self.get_id_for( sc_user_id )
		raise ArgumentError, "User ID is nil!" if sc_user_id == nil

		user_id = Digest::SHA512.new << sc_user_id.to_s
		user_id = user_id.to_s
		return user_id
	end

	# checks if user exists in local database
	# OUT true, if user exists
	def self.user_exists?( sc_user_id )
		raise ArgumentError, "User ID is nil!" if sc_user_id == nil

		# hash user id
		user_id = self.get_id_for( sc_user_id )

		return User.filter( :user_id => user_id ).first != nil
	end

	# updates the tracks of the user
	# IN soundcloud auth token
	# OUT nothing
	def self.update_tracks( token )
		raise ArgumentError, "Token is nil!" if token == nil

		favs = SoundcloudHelper.fetch_favs( token )
		user_id = self.get_id_for( SoundcloudHelper.fetch_own_id( token ) )
		# get user
		user = User.filter( :user_id => user_id ).first

		# update tracks
		sc_track_ids = favs.map( &:id ) 
		track_ids = user.tracks.collect{ |t| t[ :track_id] }

		# remove duplicates in arrays
		sc_track_ids = sc_track_ids.uniq
		track_ids = track_ids.uniq

		same_tracks = sc_track_ids & track_ids 	# array intersection - these tracks will be kept
		tracks_to_add = sc_track_ids - same_tracks # array difference - these tracks need to be added
		tracks_to_remove = track_ids - sc_track_ids # array difference - these tracks will get deleted
		
		# add new
		tracks_to_add.each do |track|
			# check if track exists
			if Track.filter( :track_id => track ).empty?
				new_track = Track.create( :track_id => track )
				new_track.add_user( user )
				new_track.save
			else
				Track.filter( :track_id => track ).first.add_user( user )
			end
		end

		# remove old
		if !user.tracks.empty?
			user.tracks.each do |track|
				if tracks_to_remove.include?( track[ :track_id ] )
					user.remove_track( track )
				end
			end
		end
	end

	# sums the tracks for each artist in the playlist
	# IN soundcloud auth token
	# OUT array consisting of (artist, count) pairs
	def self.get_missing_followings( token )
		raise ArgumentError, "Token cannot be null." if token == nil

		# get favs of followings
		followings = SoundcloudHelper.fetch_followings( token )
		favs = SoundcloudHelper.fetch_favs( token )
		
		# get artists of those favs
		artists = []
		favs.each do |fav|
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

	# determines the size of the playlist as sets on soundcloud
	def self.get_playlist_size( user_id )
		raise ArgumentError, "User ID is nil!" if user_id == nil
		size = User.filter( :user_id => user_id ).first.tracks.count
		split = size/500 + ( size % 500 > 0 ? 1 : 0 )
		return { :size => size, :split => split}
	end

	# creates the playlist as sets on soundcloud
	def self.create_set( token, user_id, set_name )
		raise ArgumentError, "Token cannot be null." if token == nil
		raise ArgumentError, "User ID is nil!" if user_id == nil
		# collect tracks
		tracks = User.filter( :user_id => user_id ).first.tracks.collect {|track| { :id => track[:track_id] } }
		# create set
		return SoundcloudHelper.create_set( token, set_name, tracks )
	end

	# gets tracks of the playlist
	# IN auth token, user id at soundcloud, amount of tracks
	# OUT array with tracks
	def self.get_tracks( token, sc_user_id, amount )
		raise ArgumentError, "Token cannot be null." if token == nil
		raise ArgumentError, "User ID is nil!" if sc_user_id == nil
		raise ArgumentError, "Amount is nil" if amount == nil
		raise ArgumentError, "Amount " + amount.to_s + "must be greater than zero." if amount <= 0

		# get user
		user = User.filter( :user_id => sc_user_id ).first
		raise ArgumentError, "User " + sc_user_id + " does not exist!" if user == nil

		# sort tracks ascending 
		tracks = user.tracks.shuffle.sort{ |a,b| UserTrack.filter( :track_id => a.track_id, :user_id => user.user_id).first.times_served <=> UserTrack.filter( :track_id => b.track_id, :user_id => user.user_id).first.times_served }
		# take the first amount much
		tracks = tracks.take( amount ).shuffle

		$LOG.debug( tracks.collect{|t| t[:track_id]}.to_s )

		# update times served variable
		tracks.each do |track|
			# times served ++
			
			usr_track = UserTrack.filter( :track_id => track.track_id, :user_id => user.user_id ).first
			$LOG.debug( usr_track.times_served.to_s )
			usr_track.times_served += 1
			usr_track.save
		end
		full_tracks = []
		tracks.each do |track|
			full_track = SoundcloudHelper.fetch_track( token, track[ :track_id ] )
			if full_track != nil
				full_tracks.push( full_track );
			end
		end
		return full_tracks
	end
end