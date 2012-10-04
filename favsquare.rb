# encoding: utf-8

require "rubygems"
require "sinatra"
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

	register Sinatra::Session
	register Mustache::Sinatra

	require "./views/layout"

	#session
	set :session_fail, "/login"

	# logger
	$LOG = Logger.new(STDOUT)
	
	configure do
		#soundcloud
		set :sc_clientid, "fcdca5600531b2292ddc9bfe7008cac6"
		set :sc_clientsecret, "bf31fae3e89dc0f2ecda2a82b30b5ad0"
		set :sc_redirecturi, "http://localhost:9393/connect"
	end

	configure(:development) do
		set :database_host, "localhost"
		set :database_user, "xnikp"
		set :database_pwd, "xnikp"
		set :database_port, "5432"
		set :database_name, "favsquare"
		set :database_url, "postgres://xnikp:xnikp@localhost:5432/favsquare"
	end

	configure(:production) do
		set :database_host, "ec2-54-243-190-93.compute-1.amazonaws.com"
		set :database_user, "ittfincvfgtnzz"
		set :database_pwd, "2gI-ZsFecFDGxox3oWNndlgtF5"
		set :database_port, "5432"
		set :database_name, "d36h4ha2hdk3hf"
		set :database_url, "postgres://ittfincvfgtnzz:2gI-ZsFecFDGxox3oWNndlgtF5@ec2-54-243-190-93.compute-1.amazonaws.com:5432/d36h4ha2hdk3hf"
	end

	# database

	# models
	Sequel::Model.db=Sequel.postgres(
		:host => settings.database_host,
		:user => settings.database_user,
		:password => settings.database_pwd,
		:database => settings.database_name,
		:port => settings.database_port
 	) 
	Sequel::Model.plugin :force_encoding, 'UTF-8'
	require "./db/models/user"
	require "./db/models/track"
	require "./db/models/user_track"
	
	#mustache
	set :public_folder, "./public"
	set :mustache, {
		:views	=>		"./views/",
		:templates =>	"./templates/"
	}

	# nötig damit session in view verfügbar ist
	before "/*" do
		@session = session
	end

	#startseite
	get "/" do
		content_type "text/html", :charset => "utf-8"
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

	# fetches tracks for playlist
	get "/tracks/:amount" do
		session!
		tracks = FavsquareLogic.get_tracks( @session[ :token ], @session[ :user_id ], Integer( params[ :amount ] ) )
		
		content_type 'application/json', :charset => 'utf-8'
		return tracks.to_json
	end

	# displays create site
	get "/create" do
		session!
		content_type "text/html", :charset => "utf-8"
		mustache :create
	end

	post "/create" do
		session!
		okay = FavsquareLogic.create_set( @session[ :token ], @session[:user_id], params[ :set_name ])
		content_type "text/html", :charset => "utf-8"
		return okay ? 200 : 400
	end

	# get missing artists
	get "/missing" do
		session!
		artists = FavsquareLogic.get_missing_followings( @session[ :token ] )
		content_type 'application/json', :charset => 'utf-8'
		return artists.to_json
	end

	# displays missing artists
	get "/overview" do
		session!
		content_type "text/html", :charset => "utf-8"
		mustache :overview
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
		new_user = !FavsquareLogic.user_exists?( sc_user_id )
		# add if necessary
		if new_user
			@session[ :user_id ] = FavsquareLogic.create_user( sc_user_id )
			$LOG.debug( "redirect to update" )
			redirect to( "/update" )
		else
			@session[ :user_id ] = FavsquareLogic.get_id_for( sc_user_id )
			redirect to( "/playlist" )
		end
	end

	# playlist
	get "/playlist" do
		session!
		content_type "text/html", :charset => "utf-8"
		mustache :playlist
	end
end