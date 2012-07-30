class Track < Sequel::Model( Sequel.sqlite( "favsquare.db" )[ :tracks ] )
	one_to_many :user_tracks
end