class UserTrack < Sequel::Model 
	
	many_to_one :user, :key => :user_id
	many_to_one :track, :key => :track_id
	
end