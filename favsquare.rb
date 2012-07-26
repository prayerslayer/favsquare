require "rubygems"
require "sinatra/base"
require "sinatra/session"
require "mustache/sinatra"
require "soundcloud"



class Favsquare < Sinatra::Base

	enable :sessions

	register Sinatra::Session
	register Mustache::Sinatra

	require "./views/layout"


	set :session_fail, "/login"

	set :public_folder, "./public"
	set :mustache, {
		:views	=>		"./views/",
		:templates =>	"./templates/"
	}

	#startseite
	get "/" do
		mustache :index
	end

	#redirected zu soundcloud connect
	get "/login" do
		client = Soundcloud.new( :client_id => "fcdca5600531b2292ddc9bfe7008cac6",
								 :client_secret => "bf31fae3e89dc0f2ecda2a82b30b5ad0",
								 :redirect_uri => "http://localhost:9393/connect" )
		redirect client.authorize_url()
	end


	# führt die soundcloud connection durch
	get "/connect" do
		code = params[ :code ]

		client = Soundcloud.new( :client_id => "fcdca5600531b2292ddc9bfe7008cac6",
								 :client_secret => "bf31fae3e89dc0f2ecda2a82b30b5ad0",
								 :redirect_uri => "http://localhost:9393/connect" )

		access_token = client.exchange_token( :code => code )

		session_start!
		session[ :token ] = access_token[ :access_token ]
		redirect to( "/playlist" )
	end

	# playlist anzeige
	get "/playlist" do
		session!
		mustache :playlist
	end
end