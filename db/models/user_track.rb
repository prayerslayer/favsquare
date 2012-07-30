class UserTrack < Sequel::Model( Sequel.sqlite( "favsquare.db" )[ :user_tracks ] ) 

end