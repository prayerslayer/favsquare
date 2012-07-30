class User < Sequel::Model( Sequel.sqlite("favsquare.db")[ :users ] )
	one_to_many :user_tracks

end