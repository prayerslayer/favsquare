# encoding: utf-8

require "rubygems"
require "sinatra"
require "sinatra/session"
require "mustache/sinatra"
require "json"
require "sequel"

$stdout.sync = true

class Favsquare < Sinatra::Base

	register Sinatra::Session
	register Mustache::Sinatra

	require "./views/layout"

	attr_accessor :user

	#session
	set :session_fail, "/login"

	# models
	Sequel::Model.db=Sequel.postgres(
		:host => ENV['DATABASE_HOST'],
		:user => ENV['DATABASE_USER'],
		:password => ENV['DATABASE_PWD'],
		:database => ENV['DATABASE_NAME'],
		:port => ENV['DATABASE_PORT']
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

	# heroku
	set :production, ENV[ 'RACK_ENV' ] == "production"
	if ( :production ) then
		require "./herokuconnection.rb"
		puts "In Production mode!"
	end

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
		client = Soundcloud.new( :client_id => ENV['SC_CLIENTID'],
								 :client_secret => ENV['SC_CLIENTSECRET'],
								 :redirect_uri => ENV['SC_REDIRECTURI'] )
		redirect client.authorize_url(
			:scope => ENV['SC_SCOPE'] )
	end

	#logout
	get "/logout/?" do
		session_end!
		redirect to( "/" )
	end

	#try
	get "/try/?" do
		session_start!
		session[ :user_id ] = User.first[:user_id] # first user in db is testuser
		redirect to( "/playlist" )
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
		@user.email = email
		puts @user.save_changes
		
		# re-check if job is completed
		job_id = session[ :update_job_id ]
		if job_id == nil
			puts "job id is somehow nil"
			return 501
		else
			job = Job.filter( :id => job_id ).first
			# job finished when it's not in table anymore
			completed = job == nil
			if completed
				@user.send_mail( "Rain: Listen now", "Start <a href='" + ENV['BASE_URL'] + "/playlist'>listening</a>!" )
			end
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
			if :production then
				FavsquareHelper::HerokuConnection.init()
				if FavsquareHelper::HerokuConnection.worker_count <= 0 then
					FavsquareHelper::HerokuConnection.hire_worker
				end
			end
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
				if :production then
					FavsquareHelper::HerokuConnection.init()
					if FavsquareHelper::HerokuConnection.worker_count <= 0 then
						FavsquareHelper::HerokuConnection.hire_worker
					end
				end
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

		client = Soundcloud.new( :client_id => ENV['SC_CLIENTID'],
								 :client_secret => ENV['SC_CLIENTSECRET'],
								 :redirect_uri => ENV['SC_REDIRECTURI'],
								 :scope => ENV['SC_SCOPE'] )

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