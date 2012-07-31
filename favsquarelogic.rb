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

		return User.filter( :sc_user_id => user_id ).empty?
	end

	def self.update_tracks( token )
		raise ArgumentError, "Token is nil!" if token == nil

		favs = SoundcloudHelper.fetch_favs( token )

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
				new_track = Track.create( :sc_track_id=> track, :embed_code => nil )	# track embed code is loaded as needed
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
		raise ArgumentError, "Amount must be greater than zero." if amount <= 0

		# get user
		user = User.filter( :sc_user_id => sc_user_id ).first
		raise ArgumentError, "User does not exist!" if user == nil

		# sort tracks ascending 
		tracks = user.tracks.sort{ |a,b| a[ :times_served ] <= b[ :times_served ] }
		# take the first amount much
		tracks = tracks[0..amount]

		# check if tracks have embed codes
		tracks.each do |track|
			if track[ :embed_code ] == nil
				# if not fetch embed code
				embed_code = SoundcloudHelper.fetch_embed_code( token, track[ :sc_track_id ])
				encoded_embed_code = HTMLEntities.new.encode( embedcode )
				track.embed_code = encoded_embed_code
				$LOG.debug( encoded_embed_code )
				track.save
			end
		end
		embed_codes = tracks.collect{ |t| t[ :embed_code ] }
		embed_codes.each do |code|
			# decode embed codes
			code = HTMLEntities.new.decode( code )
		end
		return embed_codes
	end
end