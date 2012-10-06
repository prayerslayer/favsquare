require "soundcloud"

class SoundcloudHelper

	# fetch favs
	# IN auth token
	# OUT favorite tracks of followings
	def self.fetch_favs( token )
		raise ArgumentError, "Token cannot be null." if token == nil

		client = Soundcloud.new( :access_token => token )

		favs = []
		# get other favs
		followings = client.get( "/me/followings" )

		followings.each do |following|
			followfavs = client.get( "/users/" + following.id.to_s + "/favorites" )
			followfavs.each do |fav|
				if fav[ "streamable" ] == true && !favs.include?( fav )
					favs << fav
				end
			end
		end
		# return favs
		return favs
	end

	# creates a set with specified name and tracks on soundcloud
	def self.create_set( token, name, tracks ) 
		raise ArgumentError, "Token cannot be null." if token == nil
		raise ArgumentError, "Name cannot be null." if name == nil
		raise ArgumentError, "Tracks cannot be null." if tracks == nil

		client = Soundcloud.new( :access_token => token )
		iterations = 1
		begin
			begin
				client.post( "/playlists", :playlist => {
					:title => name + ( iterations == 1 ? "" : " "+iterations.to_s ),
					:tracks => tracks.slice!( 0, 499 )
				})
			end while tracks.size > 500
		rescue Soundcloud::ResponseError => error
			puts error.response
			return false
		end

		return true
	end

	# get followings of user
	# IN auth token
	# OUT followings
	def self.fetch_followings( token )
		raise ArgumentError, "Token cannot be null." if token == nil

		client = Soundcloud.new( :access_token => token )
		begin
			followings = client.get("/me/followings").collect {|following| following[ :id ]}
		rescue Soundcloud::ResponseError => error
			puts error.response
			return nil
		end
		return followings
	end

	# gets 1 track
	# IN auth token, track id
	# OUT full track or nil if not streamable
	def self.fetch_track( token, track_id )
		raise ArgumentError, "Token cannot be null." if token == nil
		raise ArgumentError, "Track ID is null." if track_id == nil

		client = Soundcloud.new( :access_token => token )
		begin
			track = client.get( "/tracks/"+track_id.to_s )
		rescue Soundcloud::ResponseError => error
			puts error.response
			return nil
		end
		return track[ "streamable" ] ? track : nil
	end

	# get own user id
	def self.fetch_own_id( token )
		raise ArgumentError, "Token cannot be null." if token == nil

		client = Soundcloud.new( :access_token => token )
		me = client.get( "/me" )
		return me[:id]
	end

	# get own name
	def self.fetch_own_name( token )
		raise ArgumentError, "Token cannot be null." if token == nil

		client = Soundcloud.new( :access_token => token )
		me = client.get( "/me" )
		return me[:username].to_s
	end

end