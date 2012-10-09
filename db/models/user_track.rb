class UserTrack < Sequel::Model 
	
	many_to_one :user
	many_to_one :track
	
end