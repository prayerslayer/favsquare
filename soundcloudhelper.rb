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

	# get own user id
	def self.get_own_id( token )
		raise ArgumentError, "Token cannot be null." if token == nil

		client = Soundcloud.new( :access_token => token )
		me = client.get( "/me" )
		return me[:id]
	end
end