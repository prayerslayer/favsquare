# encoding: utf-8

require "soundcloud"

module FavsquareHelper
	class SoundcloudHelper

		# fetch favs
		# IN auth token
		# OUT favorite tracks of followings
		def self.fetch_favs( token )
			raise ArgumentError, "Token cannot be null." if token == nil

			client = Soundcloud.new( :access_token => token )

			favs = {}
			# get other favs
			followings = client.get( "/me/followings" )

			followings.each do |following|
				followfavs = client.get( "/users/" + following.id.to_s + "/favorites" )
				followfavs.each do |fav|
					if fav[ :streamable ] == true && !favs.include?( fav )
						fav.faved_by = following.id
						favs[ fav.id ] = fav
					end
				end
			end
			# return favs
			return favs
		end

		# get followings of user
		# IN auth token
		# OUT followings
		def self.fetch_followings( token )
			raise ArgumentError, "Token cannot be null." if token == nil

			client = Soundcloud.new( :access_token => token )
			begin
				followings = client.get( "/me/followings" ).collect { |following| following[ :id ] }
			rescue Net::HTTPGatewayTimeout => tout
				puts tout.response
				return nil
			end
			rescue Soundcloud::ResponseError => error
				puts error.response
				return nil
			end
			return followings
		end

		# get user info
		# IN auth token, user id
		# OUT full user
		def self.fetch_user_info( token, user_id )
			raise ArgumentError, "Token cannot be null." if token == nil
			raise ArgumentError, "User ID cannot be null." if user_id == nil

			client = Soundcloud.new( :access_token => token )

			begin
				user = client.get( "/users/"+user_id.to_s )
			rescue Net::HTTPGatewayTimeout => tout
				puts tout.response
				return nil
			end
			rescue Soundcloud::ResponseError => error
				puts error
				puts error.response
				return {:username => "Unkown", :permalink_url => ""}
			end
			return user
		end
	end
end