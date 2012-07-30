require "rubygems"
require "sinatra/base"
require "sinatra/session"
require "mustache/sinatra"
require "soundcloud"
require "./soundcloudhelper"


class Favsquare < Sinatra::Base

	enable :sessions

	register Sinatra::Session
	register Mustache::Sinatra

	require "./views/layout"

	#session
	set :session_fail, "/"
	
	#soundcloud
	configure do
		set :sc_clientid, "fcdca5600531b2292ddc9bfe7008cac6"
		set :sc_clientsecret, "bf31fae3e89dc0f2ecda2a82b30b5ad0"
		set :sc_redirecturi, "http://localhost:9393/connect"
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
		mustache :load
		SoundcloudHelper.fetch_favs( @session[ :token ] )
		mustache :playlist
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
		#session[ :client ] = client
		redirect to( "/load" )
	end

	# playlist anzeige
	get "/playlist" do
		session!
		mustache :playlist
	end
end