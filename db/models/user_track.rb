class UserTrack < Sequel::Model 
	
	many_to_one :user, :key => :sc_user_id
	many_to_one :track, :key => :sc_track_id
	
end