require "digest/sha2"
require "sequel"
require "./soundcloudhelper"
require "htmlentities"

class FavsquareLogic

	def self.create_user( sc_user_id )
		raise ArgumentError, "User ID is nil!" if sc_user_id == nil

		user_id = self.get_id_for( sc_user_id )
		new_user = User.create( :sc_user_id => user_id )
		new_user.save
		return user_id

	end

	def self.get_id_for( sc_user_id )
		raise ArgumentError, "User ID is nil!" if sc_user_id == nil

		user_id = Digest::SHA512.new << sc_user_id.to_s
		user_id = user_id.to_s
		return user_id
	end

	def self.user_exists?( sc_user_id )
		raise ArgumentError, "User ID is nil!" if sc_user_id == nil

		# hash user id
		sc_user_id = self.get_id_for( sc_user_id )

		return User.filter( :sc_user_id => sc_user_id ).first != nil
	end

	def self.update_tracks( token )
		raise ArgumentError, "Token is nil!" if token == nil

		favs = SoundcloudHelper.fetch_favs( token )
		user_id = self.get_id_for( SoundcloudHelper.fetch_own_id( token ) )
		# get user
		user = User.filter( :sc_user_id => user_id ).first

		# update tracks
		sc_track_ids = favs.map( &:id ) 
		track_ids = user.tracks.collect{ |t| t[ :sc_track_id] }

		# remove duplicates in arrays
		sc_track_ids = sc_track_ids.uniq
		track_ids = track_ids.uniq

		same_tracks = sc_track_ids & track_ids 	# array intersection - these tracks will be kept
		tracks_to_add = sc_track_ids - same_tracks # array difference - these tracks need to be added
		tracks_to_remove = track_ids - sc_track_ids # array difference - these tracks will get deleted
		
		# add new
		tracks_to_add.each do |track|
			# check if track exists
			if Track.filter( :sc_track_id => track ).empty?
				new_track = Track.create( :sc_track_id => track )
				new_track.add_user( user )
				new_track.save
			else
				Track.filter( :sc_track_id => track ).first.add_user( user )
			end
		end

		# remove old
		if !user.tracks.empty?
			user.tracks.each do |track|
				if tracks_to_remove.include?( track[ :sc_track_id ] )
					user.remove_track( track )
				end
			end
		end

	end


	def self.get_tracks( token, sc_user_id, amount )
		raise ArgumentError, "Token cannot be null." if token == nil
		raise ArgumentError, "User ID is nil!" if sc_user_id == nil
		raise ArgumentError, "Amount is nil" if amount == nil
		raise ArgumentError, "Amount " + amount.to_s + "must be greater than zero." if amount <= 0

		# get user
		user = User.filter( :sc_user_id => sc_user_id ).first
		raise ArgumentError, "User " + sc_user_id + " does not exist!" if user == nil

		# sort tracks ascending 
		tracks = user.tracks.shuffle.sort{ |a,b| UserTrack.filter( :track_id => a.track_id, :user_id => user.user_id).first.times_served <=> UserTrack.filter( :track_id => b.track_id, :user_id => user.user_id).first.times_served }
		# take the first amount much
		tracks = tracks.take( amount ).shuffle

		$LOG.debug( tracks.collect{|t| t[:track_id]}.to_s )
		coder = HTMLEntities.new
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
			begin
				full_tracks.push( SoundcloudHelper.fetch_track( token, track[ :sc_track_id ] ) );
			rescue Soundcloud::ResponseError => e
				puts e
			end
		end
		return full_tracks
	end
end