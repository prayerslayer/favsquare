class User < Sequel::Model( Sequel.sqlite("favsquare.db")[ :users ] )
	many_to_many :tracks

end