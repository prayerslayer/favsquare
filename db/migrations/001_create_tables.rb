Sequel.migration do
	change do
		# create table users
		create_table(:users) do
			primary_key :user_id 				# own user id
			String :sc_user_id, :null => false 	# because we want to store a hash of the user id
		end

		# table tracks
		create_table(:tracks) do
			primary_key :track_id
			Integer :sc_track_id, :null => false
		end

		# table user_tracks
		create_table(:tracks_users) do
			foreign_key(:track_id, :key => :sc_track_id)
			foreign_key(:user_id, :key => :sc_user_id)
			primary_key([:user_id, :track_id])
			Integer :times_served, :default => 0
		end
	end
end