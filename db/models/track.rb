class Track < Sequel::Model( Sequel.sqlite( "favsquare.db" )[ :tracks ] )
	many_to_many :users
end