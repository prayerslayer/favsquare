require "rubygems"
require "sinatra/base"
require "sinatra/session"
require "mustache/sinatra"
require "soundcloud"
require "sqlite3"
require "sequel"
require "./soundcloudhelper"


class Favsquare < Sinatra::Base

	enable :sessions

	register Sinatra::Session
	register Mustache::Sinatra

	require "./views/layout"
	# models
	require "./db/models/user"

	#session
	set :session_fail, "/"
	
	#soundcloud
	configure do
		set :sc_clientid, "fcdca5600531b2292ddc9bfe7008cac6"
		set :sc_clientsecret, "bf31fae3e89dc0f2ecda2a82b30b5ad0"
		set :sc_redirecturi, "http://localhost:9393/connect"

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
		@database ||= Sequel.connect( settings.database_url, :encoding => 'utf-8' )
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

		# check if user exists
		# hash user id because we don't need it in plaintext
		user_id = Digest::SHA512.new << SoundcloudHelper.get_own_id( @session[ :token ] ).to_s
		user_id = user_id.to_s
		new_user = User.filter( :sc_user_id => user_id ).empty?

		# if user is new, add her to database
		user = nil
		if new_user
			user = User.create( :sc_user_id => user_id )
		else
			user = User.filter( :sc_user_id => user_id )
		end

		@session[ :user_id ] = user_id


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

		redirect to( "/load" )
	end

	# playlist anzeige
	get "/playlist" do
		session!
		mustache :playlist
	end
end