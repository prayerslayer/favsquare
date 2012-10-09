Sequel.migration do
	change do
		# create table users
		create_table(:users) do
			String :user_id, :null => false 	# because we want to store a hash of the user id
			primary_key :user_id
		end

		# table tracks
		create_table(:tracks) do
			Integer :track_id, :null => false
			primary_key :track_id
		end

		# table user_tracks
		create_table(:user_tracks) do
			foreign_key :track_id, :tracks, :null => false
			foreign_key :user_id, :users, :null => false
			primary_key( [ :user_id, :track_id ] )
			Integer :times_served, :default => 0
		end
	end
end