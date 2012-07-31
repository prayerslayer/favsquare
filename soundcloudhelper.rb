require "soundcloud"

class SoundcloudHelper

	# fetch favs for given token
	def self.fetch_favs( token )
		raise ArgumentError, "Token cannot be null." if token == nil

		client = Soundcloud.new( :access_token => token )

		# get own favs
		favs = client.get( "/me/favorites" )
		# get other favs
		followings = client.get( "/me/followings" )
		followings.each do |following|
			followfavs = client.get( "/users/"+following.id.to_s+"/tracks" )
			followfavs.each do |fav|
				favs << fav
			end
		end
		# return favs
		favs
	end

	def self.fetch_track( token, track_id )
		raise ArgumentError, "Token cannot be null." if token == nil
		raise ArgumentError, "Track ID is null." if track_id == nil

		client = Soundcloud.new( :access_token => token )
		return client.get("/tracks/"+track_id.to_s)
	end


	def self.fetch_embed_code( token, track_id )
		raise ArgumentError, "Token cannot be null." if token == nil
		raise ArgumentError, "Track ID is null." if track_id == nil

		client = Soundcloud.new( :access_token => token )
		track = self.fetch_track( token, track_id )
		oembed = client.get( "/oembed", :format => "json", :url => track[ :permalink_url ] )
		return oembed.html
	end

	# get own user id
	def self.fetch_own_id( token )
		raise ArgumentError, "Token cannot be null." if token == nil

		client = Soundcloud.new( :access_token => token )
		me = client.get( "/me" )
		return me[:id]
	end

	def self.fetch_own_name( token )
		raise ArgumentError, "Token cannot be null." if token == nil

		client = Soundcloud.new( :access_token => token )
		me = client.get( "/me" )
		return me[:username].to_s
	end

end