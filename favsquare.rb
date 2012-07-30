require "rubygems"
require "sinatra/base"
require "sinatra/session"
require "mustache/sinatra"
require "soundcloud"
require "sqlite3"
require "sequel"
require "logger"
require "./soundcloudhelper"


class Favsquare < Sinatra::Base

	enable :sessions

	register Sinatra::Session
	register Mustache::Sinatra

	require "./views/layout"
	# models
	require "./db/models/user"
	require "./db/models/track"
	require "./db/models/user_track"

	#session
	set :session_fail, "/"

	# logger
	$LOG = Logger.new(STDOUT)
	
	configure do
		#soundcloud
		set :sc_clientid, "fcdca5600531b2292ddc9bfe7008cac6"
		set :sc_clientsecret, "bf31fae3e89dc0f2ecda2a82b30b5ad0"
		set :sc_redirecturi, "http://localhost:9393/connect"
		#sequel
		set :database_url, "sqlite://favsquare.db"
	end
	
	#mustache
	set :public_folder, "./public"
	set :mustache, {
		:views	=>		"./views/",
		:templates =>	"./templates/"
	}

	# nötig damit session in view verfügbar ist
	before do
		@session = session
	end

	#startseite
	get "/" do
		mustache :index
	end

	#redirected zu soundcloud connect
	get "/login" do
		client = Soundcloud.new( :client_id => settings.sc_clientid,
								 :client_secret => settings.sc_clientsecret,
								 :redirect_uri => settings.sc_redirecturi )
		redirect client.authorize_url()
	end

	#logout
	get "/logout" do
		session_end!
		redirect to( "/" )
	end

	get "/load" do
		# how to inform the client that everything is ready?
		
		# fetch favs from user
		favs = SoundcloudHelper.fetch_favs( @session[ :token ] )

		
		# hash user id because we don't need it in plaintext
		user_id = Digest::SHA512.new << SoundcloudHelper.get_own_id( @session[ :token ] ).to_s
		user_id = user_id.to_s
		@session[ :user_id ] = user_id
		# check if user exists
		new_user = User.filter( :sc_user_id => user_id ).empty?

		# if user is new, add her to database
		user = nil
		if new_user
			user = User.create( :sc_user_id => user_id )
			user.save
		else
			user = User.filter( :sc_user_id => user_id ).first
		end

		# update tracks
		sc_track_ids = favs.map( &:id ) 
		track_ids = user.tracks.collect{ |t| t[ :sc_track_id] }

		# remove duplicates in arrays
		sc_track_ids = sc_track_ids.uniq
		track_ids = track_ids.uniq
		
		$LOG.debug( "own tracks: "+track_ids.inspect )
		$LOG.debug( "sc tracks: "+sc_track_ids.inspect )

		same_tracks = sc_track_ids & track_ids 	# array intersection - these tracks will be kept
		tracks_to_add = sc_track_ids - same_tracks # array difference - these tracks need to be added
		tracks_to_remove = track_ids - sc_track_ids # array difference - these tracks will get deleted
		
		# add new
		tracks_to_add.each do |track|
			$LOG.debug("adding new track "+track.to_s)
			# check if track exists
			if Track.filter( :sc_track_id => track ).empty?
				$LOG.debug("created track with id " + track.to_s)
				new_track = Track.create( :sc_track_id=> track, :embed_code => nil )	# track embed code is loaded as needed
				$LOG.debug("adding to user "+user_id)
				new_track.add_user( user )
				new_track.save
			else
				$LOG.debug("user "+user.to_s)
				Track.filter( :sc_track_id => track ).first.add_user( user )
			end
		end

		# remove old
		if !user.tracks.empty?
			user.tracks.filter( :track_id => tracks_to_remove ).delete
			user.tracks.save
		end

		# redirect to playlist
		redirect to( "/playlist" )
	end

	# führt die soundcloud connection durch
	get "/connect" do
		code = params[ :code ]

		client = Soundcloud.new( :client_id => settings.sc_clientid,
								 :client_secret => settings.sc_clientsecret,
								 :redirect_uri => settings.sc_redirecturi )

		access_token = client.exchange_token( :code => code )

		session_start!
		session[ :token ] = access_token[ :access_token ]
		session[ :user_name ] = SoundcloudHelper.get_own_name( session[ :token] )
		redirect to( "/load" )
	end

	# playlist anzeige
	get "/playlist" do
		session!
		mustache :playlist
	end
end