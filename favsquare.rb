require "rubygems"
require "sinatra/base"
require "sinatra/session"
require "mustache/sinatra"
require "soundcloud"
require "sqlite3"
require "sequel"
require "json"
require "logger"
require "./soundcloudhelper"
require "./favsquarelogic"

class Favsquare < Sinatra::Base

	enable :sessions

	register Sinatra::Session
	register Mustache::Sinatra

	require "./views/layout"
	# models
	Sequel::Model.plugin :force_encoding, 'UTF-8'
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

	get "tracks/:amount" do
		session!

		tracks = FavsquareLogic.get_tracks( @session[ :token ], @session[ :user_id ], Integer( params[ :amount ] ) )
		return tracks.to_json
	end

	# update saved tracks
	get "/update" do
		# how to inform the client that everything is ready?
		session!
		FavsquareLogic.update_tracks( @session[ :token ] )

		# redirect to playlist
		redirect to( "/playlist" )
	end

	# executes the soundcloud connection
	get "/connect" do
		code = params[ :code ]

		client = Soundcloud.new( :client_id => settings.sc_clientid,
								 :client_secret => settings.sc_clientsecret,
								 :redirect_uri => settings.sc_redirecturi )

		access_token = client.exchange_token( :code => code )

		session_start!
		session[ :token ] = access_token[ :access_token ]
		session[ :user_name ] = SoundcloudHelper.fetch_own_name( session[ :token] )

		# hash user id because we don't need it in plaintext
		sc_user_id = SoundcloudHelper.fetch_own_id( @session[ :token ] ).to_s
		
		# check if user exists
		new_user = FavsquareLogic.user_exists( sc_user_id )
		# add if necessary
		if new_user
			@session[ :user_id ] = FavsquareLogic.create_user( sc_user_id )
			redirect to( "/update" )
		else
			@session[ :user_id ] = FavsquareLogic.get_id_for( sc_user_id )
			redirect to( "/playlist" )
		end
	end

	# playlist
	get "/playlist" do
		session!

		mustache :playlist
	end
end