# encoding: utf-8

require "rubygems"
require "sinatra"
require "sinatra/session"
require "mustache/sinatra"
require "logger"
require "json"
require "sequel"


class Favsquare < Sinatra::Base

	register Sinatra::Session
	register Mustache::Sinatra

	require "./views/layout"

	attr_accessor :user

	#session
	set :session_fail, "/login"

	# logger
	$LOG = Logger.new(STDOUT)
	
	configure do
		#soundcloud
		set :sc_scope, "non-expiring"
	end

	configure(:development) do
		set :base_url, "http://localhost:9393"
		set :session_secret, "meine sessions sind 3mal so sicher wie deine"
		set :database_host, "localhost"
		set :database_user, "xnikp"
		set :database_pwd, "xnikp"
		set :database_port, "5432"
		set :database_name, "favsquare"
		set :sc_clientid, "f928c3bc1abd9ffc4c6455d13ababa9d"
		set :sc_clientsecret, "153e2f56c17457b52e9330f9b9c58aac"
		set :sc_redirecturi, "http://localhost:9393/connect"
		set :database_url, "postgres://xnikp:xnikp@localhost:5432/favsquare"
	end

	configure(:production) do
		set :base_url, "http://obscure-basin-1623.herokuapp.com"
		set :session_secret, "meine sessions sind 3mal so sicher wie deine"
		set :database_host, "ec2-54-243-190-93.compute-1.amazonaws.com"
		set :database_user, "ittfincvfgtnzz"
		set :database_pwd, "2gI-ZsFecFDGxox3oWNndlgtF5"
		set :database_port, "5432"
		set :database_name, "d36h4ha2hdk3hf"
		set :sc_clientid, "fcdca5600531b2292ddc9bfe7008cac6"
		set :sc_clientsecret, "bf31fae3e89dc0f2ecda2a82b30b5ad0"
		set :sc_redirecturi, "http://obscure-basin-1623.herokuapp.com/connect"
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
	require "./db/models/job"
	require "navvy"
	require "navvy/job/sequel"
	
	#mustache
	set :public_folder, "./public"
	set :mustache, {
		:views	=>		"./views/",
		:templates =>	"./templates/"
	}

	before "/*" do
		@session = session
		@user = nil
		if session[ :user_id ] != nil
			@user = User.filter( :user_id => session[:user_id] ).first
		end
	end

	#startseite
	get "/" do
		content_type "text/html", :charset => "utf-8"
		mustache :index
	end

	#redirected zu soundcloud connect
	get "/login/?" do
		client = Soundcloud.new( :client_id => settings.sc_clientid,
								 :client_secret => settings.sc_clientsecret,
								 :redirect_uri => settings.sc_redirecturi )
		redirect client.authorize_url(
			:scope => settings.sc_scope )
	end

	#logout
	get "/logout/?" do
		session_end!
		redirect to( "/" )
	end

	# fetches tracks for playlist
	get "/tracks/:amount/?" do
		session!
		tracks = @user.get_playlist_tracks( Integer( params[ :amount ] ) )
		
		content_type 'application/json', :charset => 'utf-8'
		return tracks.to_json
	end

	# displays create site
	get "/create/?" do
		session!
		
		content_type "text/html", :charset => "utf-8"
		mustache :create, :locals => { :num_tracks => @user.playlist_size }
	end

	post "/create/?" do
		session!
		
		okay = @user.create_set()
		content_type "text/html", :charset => "utf-8"
		return okay ? 200 : 400
	end

	post "/add_email/?" do
		session!

		email = params[:email]
		puts email
		session[:user_email] = email
		@user.email = email
		puts @user.save_changes
		if session[:update_job_completed]
			@user.send_mail( "Rain: Listen now", "Start <a href='" + settings.base_url + "/playlist'>listening</a>!" )
		end

		return 200
	end

	# update saved tracks
	get "/update/?" do
		session!
		user_id = session[:user_id]
		
		job_id = session[ :update_job_id ]

		if job_id == nil
			# user never ran a job
			job = Navvy::Job.enqueue( User, :update_tracks, user_id )
			puts job.id
			puts job.completed?
			session[ :update_job_id ] = job.id
			session[ :update_job_completed ] = job.completed?

		else
			# user ran a job before
			job = Job.filter( :id => job_id ).first
			# job finished when it's not in table anymore
			completed = job == nil
			# did it complete?
			if completed
				# start new
				job = Navvy::Job.enqueue( User, :update_tracks, user_id )
				session[ :update_job_id ] = job.id
			end
			# set the completed status
			session[ :update_job_completed ] = completed
		end
	
		mustache :update
	end

	# executes the soundcloud connection
	get "/connect/?" do
		code = params[ :code ]

		client = Soundcloud.new( :client_id => settings.sc_clientid,
								 :client_secret => settings.sc_clientsecret,
								 :redirect_uri => settings.sc_redirecturi,
								 :scope => settings.sc_scope )

		access_token = client.exchange_token( :code => code )

		session_start!
		
		sc_user_id = client.get("/me")[:id].to_s
		
		# check if user exists
		new_user = !User.exists?( sc_user_id )

		puts "user " + sc_user_id + " is " + ( new_user ? "new" : "old" )
		
		# add if necessary
		if new_user
			user = User.create_user( sc_user_id )
		else
			user = User.filter( :user_id => User.id_for( sc_user_id ) ).first
		end

		user[:token] = access_token[:access_token]
		user.save

		session[:user_name] = user.username
		session[:user_id] = user.user_id

		if new_user
			redirect to( "/update" )
		else
			redirect to( "/playlist" )
		end
	end

	# playlist
	get "/playlist/?" do
		session!
		content_type "text/html", :charset => "utf-8"
		mustache :playlist
	end
end