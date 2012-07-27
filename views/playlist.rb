require "sinatra/base"
require "sinatra/session"
require "soundcloud"

class Favsquare

	module Views

		class Playlist < Layout

			def tracks
				# if the favorites haven't been fetched yet, do so
				client = Soundcloud.new( :access_token => @session[ :token ] )
				if @session[ :favs_page ] == nil
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

					@session[ :favs ] = favs.shuffle.each_slice(10).to_a
					@session[ :favs_page] = 0
				end

				# get embed code for tracks
				@session[ :favs ].at( @session[ :favs_page] ).each do |track|
					if track.embed_code == nil
						url = track.permalink_url
						embed_info = client.get( "/oembed", :format => "json", :url => url)
						track.embed_code = embed_info.html
					end
				end
				@session[ :favs ].at( @session[ :favs_page] )
			end

			def followings
				client = Soundcloud.new( :access_token => @session[ :token ] )
				client.get( "/me/followings" )

			end

		end

	end

end